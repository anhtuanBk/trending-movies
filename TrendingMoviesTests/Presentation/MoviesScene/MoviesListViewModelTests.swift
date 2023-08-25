import XCTest

class MoviesListViewModelTests: XCTestCase {
    
    private enum TrendingMoviesUseCaseError: Error {
        case someError
    }
    
    private enum SearchMoviesUseCaseError: Error {
        case someError
    }
    
    let moviesPages: [MoviesPage] = {
        let page1 = MoviesPage(page: 1, totalPages: 2, movies: [
            Movie.stub(id: "1", title: "title1", posterPath: "/1", overview: "overview1", voteAverage: 1.1),
            Movie.stub(id: "2", title: "title2", posterPath: "/2", overview: "overview2", voteAverage: 2.2)])
        let page2 = MoviesPage(page: 2, totalPages: 2, movies: [
            Movie.stub(id: "3", title: "title3", posterPath: "/3", overview: "overview3", voteAverage: 3.3)])
        return [page1, page2]
    }()
    
    class TrendingMoviesUseCaseMock: TrendingMoviesUseCase {
        var executeCallCount: Int = 0

        typealias ExecuteBlock = (
            TrendingMoviesUseCaseRequestValue,
            (MoviesPage) -> Void,
            (Result<MoviesPage, Error>) -> Void
        ) -> Void

        lazy var _execute: ExecuteBlock = { _, _, _ in
            XCTFail("not implemented")
        }
        
        func execute(
            requestValue: TrendingMoviesUseCaseRequestValue,
            cached: @escaping (MoviesPage) -> Void,
            completion: @escaping (Result<MoviesPage, Error>) -> Void
        ) -> Cancellable? {
            executeCallCount += 1
            _execute(requestValue, cached, completion)
            return nil
        }
    }
    
    class SearchMoviesUseCaseMock: SearchMoviesUseCase {
        var executeCallCount: Int = 0

        typealias ExecuteBlock = (
            SearchMoviesUseCaseRequestValue,
            (MoviesPage) -> Void,
            (Result<MoviesPage, Error>) -> Void
        ) -> Void

        lazy var _execute: ExecuteBlock = { _, _, _ in
            XCTFail("not implemented")
        }
        
        func execute(
            requestValue: SearchMoviesUseCaseRequestValue,
            cached: @escaping (MoviesPage) -> Void,
            completion: @escaping (Result<MoviesPage, Error>) -> Void
        ) -> Cancellable? {
            executeCallCount += 1
            _execute(requestValue, cached, completion)
            return nil
        }
    }
    
    func test_whenTrendingMoviesUseCaseRetrievesEmptyPage_thenViewModelIsEmpty() {
        // given
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()

        trendingMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 1)
            completion(.success(MoviesPage(page: 1, totalPages: 0, movies: [])))
        }
        let viewModel = DefaultMoviesListViewModel(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock,
            mainQueue: DispatchQueueTypeMock()
        )
        // when
        viewModel.viewDidLoad()
        
        // then
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertTrue(viewModel.items.value.isEmpty)
        XCTAssertEqual(trendingMoviesUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenTrendingMoviesUseCaseRetrievesFirstPage_thenViewModelContainsOnlyFirstPage() {
        // given
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()

        trendingMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 1)
            completion(.success(self.moviesPages[0]))
        }
        let viewModel = DefaultMoviesListViewModel(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock,
            mainQueue: DispatchQueueTypeMock()
        )
        // when
        viewModel.viewDidLoad()
        
        // then
        let expectedItems = moviesPages[0]
            .movies
            .map { MoviesListItemViewModel(movie: $0) }
        XCTAssertEqual(viewModel.items.value, expectedItems)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(trendingMoviesUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenTrendingMoviesUseCaseRetrievesFirstAndSecondPage_thenViewModelContainsTwoPages() {
        // given
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()

        trendingMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 1)
            completion(.success(self.moviesPages[0]))
        }
        let viewModel = DefaultMoviesListViewModel.make(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock
        )
        // when
        viewModel.viewDidLoad()
        XCTAssertEqual(trendingMoviesUseCaseMock.executeCallCount, 1)
        
        trendingMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 2)
            completion(.success(self.moviesPages[1]))
        }

        viewModel.didLoadNextPage()

        // then
        let expectedItems = moviesPages
            .flatMap { $0.movies }
            .map { MoviesListItemViewModel(movie: $0) }
        XCTAssertEqual(viewModel.items.value, expectedItems)
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertEqual(trendingMoviesUseCaseMock.executeCallCount, 2)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }

    func test_whenTrendingMoviesUseCaseReturnsError_thenViewModelContainsError() {
        // given
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        
        trendingMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 1)
            completion(.failure(TrendingMoviesUseCaseError.someError))
        }
        let viewModel = DefaultMoviesListViewModel.make(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock
        )
        // when
        viewModel.viewDidLoad()

        // then
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.items.value.isEmpty)
        XCTAssertEqual(trendingMoviesUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenTrendingMoviesLastPage_thenHasNoPageIsTrue() {
        // given
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        trendingMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 1)
            completion(.success(self.moviesPages[0]))
        }
        let viewModel = DefaultMoviesListViewModel.make(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock
        )
        // when
        viewModel.viewDidLoad()
        XCTAssertEqual(trendingMoviesUseCaseMock.executeCallCount, 1)

        trendingMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 2)
            completion(.success(self.moviesPages[1]))
        }

        viewModel.didLoadNextPage()

        // then
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertEqual(trendingMoviesUseCaseMock.executeCallCount, 2)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenTrendingMoviesUseCaseReturnsCachedData_thenViewModelShowsFirstCachedDataAndAfterFreshData() {
        // given
        let cachedPage: MoviesPage = .init(
            page: 1,
            totalPages: 2,
            movies: [.stub(id: "cachedMovieId1")]
        )
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        
        let viewModel = DefaultMoviesListViewModel(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock,
            mainQueue: DispatchQueueTypeMock()
        )
        
        let testItemsBeforeFreshData = { [weak viewModel] in
            guard let viewModel else { return }
            let expectedItems = cachedPage
                .movies
                .map { MoviesListItemViewModel(movie: $0) }
        
            XCTAssertEqual(viewModel.items.value, expectedItems)
        }

        trendingMoviesUseCaseMock._execute = { requestValue, cached, completion in
            XCTAssertEqual(requestValue.page, 1)
            cached(cachedPage)
            testItemsBeforeFreshData()
            completion(.success(self.moviesPages[0]))
        }
        
        // when
        viewModel.viewDidLoad()

        // then
        let expectedItems = moviesPages[0]
            .movies
            .map { MoviesListItemViewModel(movie: $0) }
        XCTAssertEqual(viewModel.items.value, expectedItems)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(trendingMoviesUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenTrendingMoviesUseCaseReturnsError_thenViewModelShowsCachedData() {
        // given
        let cachedPage: MoviesPage = .init(
            page: 1,
            totalPages: 2,
            movies: [.stub(id: "cachedMovieId1")]
        )
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        
        let viewModel = DefaultMoviesListViewModel(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock,
            mainQueue: DispatchQueueTypeMock()
        )

        trendingMoviesUseCaseMock._execute = { requestValue, cached, completion in
            XCTAssertEqual(requestValue.page, 1)
            cached(cachedPage)
            completion(.failure(TrendingMoviesUseCaseError.someError))
        }
        
        // when
        viewModel.viewDidLoad()

        // then
        let expectedItems = cachedPage
            .movies
            .map { MoviesListItemViewModel(movie: $0) }
        XCTAssertEqual(viewModel.items.value, expectedItems)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(trendingMoviesUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenSearchMoviesUseCaseRetrievesEmptyPage_thenViewModelIsEmpty() {
        // given
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()

        searchMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 1)
            completion(.success(MoviesPage(page: 1, totalPages: 0, movies: [])))
        }
        let viewModel = DefaultMoviesListViewModel(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock,
            mainQueue: DispatchQueueTypeMock()
        )
        // when
        viewModel.didSearch(query: "query")
        
        // then
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertTrue(viewModel.items.value.isEmpty)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenSearchMoviesUseCaseRetrievesFirstPage_thenViewModelContainsOnlyFirstPage() {
        // given
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()

        searchMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 1)
            completion(.success(self.moviesPages[0]))
        }
        let viewModel = DefaultMoviesListViewModel(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock,
            mainQueue: DispatchQueueTypeMock()
        )
        // when
        viewModel.didSearch(query: "query")
        
        // then
        let expectedItems = moviesPages[0]
            .movies
            .map { MoviesListItemViewModel(movie: $0) }
        XCTAssertEqual(viewModel.items.value, expectedItems)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenSearchMoviesUseCaseRetrievesFirstAndSecondPage_thenViewModelContainsTwoPages() {
        // given
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()

        searchMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 1)
            completion(.success(self.moviesPages[0]))
        }
        let viewModel = DefaultMoviesListViewModel.make(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock
        )
        // when
        viewModel.didSearch(query: "query")
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
        
        searchMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 2)
            completion(.success(self.moviesPages[1]))
        }

        viewModel.didLoadNextPage()

        // then
        let expectedItems = moviesPages
            .flatMap { $0.movies }
            .map { MoviesListItemViewModel(movie: $0) }
        XCTAssertEqual(viewModel.items.value, expectedItems)
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 2)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }

    func test_whenSearchMoviesUseCaseReturnsError_thenViewModelContainsError() {
        // given
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        
        searchMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 1)
            completion(.failure(SearchMoviesUseCaseError.someError))
        }
        let viewModel = DefaultMoviesListViewModel.make(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock
        )
        // when
        viewModel.didSearch(query: "query")

        // then
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.items.value.isEmpty)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }

    func test_whenSearchMoviesLastPage_thenHasNoPageIsTrue() {
        // given
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        searchMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 1)
            completion(.success(self.moviesPages[0]))
        }
        let viewModel = DefaultMoviesListViewModel.make(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock
        )
        // when
        viewModel.didSearch(query: "query")
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)

        searchMoviesUseCaseMock._execute = { requestValue, _, completion in
            XCTAssertEqual(requestValue.page, 2)
            completion(.success(self.moviesPages[1]))
        }

        viewModel.didLoadNextPage()

        // then
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 2)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenSearchMoviesUseCaseReturnsCachedData_thenViewModelShowsFirstCachedDataAndAfterFreshData() {
        // given
        let cachedPage: MoviesPage = .init(
            page: 1,
            totalPages: 2,
            movies: [.stub(id: "cachedMovieId1")]
        )
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        
        let viewModel = DefaultMoviesListViewModel(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock,
            mainQueue: DispatchQueueTypeMock()
        )
        
        let testItemsBeforeFreshData = { [weak viewModel] in
            guard let viewModel else { return }
            let expectedItems = cachedPage
                .movies
                .map { MoviesListItemViewModel(movie: $0) }
        
            XCTAssertEqual(viewModel.items.value, expectedItems)
        }

        searchMoviesUseCaseMock._execute = { requestValue, cached, completion in
            XCTAssertEqual(requestValue.page, 1)
            cached(cachedPage)
            testItemsBeforeFreshData()
            completion(.success(self.moviesPages[0]))
        }
        
        // when
        viewModel.didSearch(query: "query")

        // then
        let expectedItems = moviesPages[0]
            .movies
            .map { MoviesListItemViewModel(movie: $0) }
        XCTAssertEqual(viewModel.items.value, expectedItems)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenSearchMoviesUseCaseReturnsError_thenViewModelShowsCachedData() {
        // given
        let cachedPage: MoviesPage = .init(
            page: 1,
            totalPages: 2,
            movies: [.stub(id: "cachedMovieId1")]
        )
        let trendingMoviesUseCaseMock = TrendingMoviesUseCaseMock()
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        
        let viewModel = DefaultMoviesListViewModel(
            trendingMoviesUseCase: trendingMoviesUseCaseMock,
            searchMoviesUseCase: searchMoviesUseCaseMock,
            mainQueue: DispatchQueueTypeMock()
        )

        searchMoviesUseCaseMock._execute = { requestValue, cached, completion in
            XCTAssertEqual(requestValue.page, 1)
            cached(cachedPage)
            completion(.failure(SearchMoviesUseCaseError.someError))
        }
        
        // when
        viewModel.didSearch(query: "query")

        // then
        let expectedItems = cachedPage
            .movies
            .map { MoviesListItemViewModel(movie: $0) }
        XCTAssertEqual(viewModel.items.value, expectedItems)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }

}

extension DefaultMoviesListViewModel {
    static func make(
        trendingMoviesUseCase: TrendingMoviesUseCase,
        searchMoviesUseCase: SearchMoviesUseCase
    ) -> DefaultMoviesListViewModel {
        DefaultMoviesListViewModel(
            trendingMoviesUseCase: trendingMoviesUseCase,
            searchMoviesUseCase: searchMoviesUseCase,
            mainQueue: DispatchQueueTypeMock()
        )
    }
}
