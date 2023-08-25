import XCTest

class SearchMoviesUseCaseTests: XCTestCase {
    
    static let moviesPages: [MoviesPage] = {
        let page1 = MoviesPage(page: 1, totalPages: 2, movies: [
            Movie.stub(id: "1", title: "title1", posterPath: "/1", overview: "overview1", voteAverage: 1.1),
            Movie.stub(id: "2", title: "title2", posterPath: "/2", overview: "overview2", voteAverage: 2.2)])
        let page2 = MoviesPage(page: 2, totalPages: 2, movies: [
            Movie.stub(id: "3", title: "title3", posterPath: "/3", overview: "overview3", voteAverage: 3.3)])
        return [page1, page2]
    }()
    
    func testSearchMoviesUseCase_whenSuccessfullyFetchesMoviesForQuery_thenQueryIsSavedInRecentQueries() {
        // given
        var useCaseCompletionCallsCount = 0
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let moviesRepository = MoviesRepositoryMock(
            result: .success(SearchMoviesUseCaseTests.moviesPages[0])
        )
        let useCase = DefaultSearchMoviesUseCase(
            moviesRepository: moviesRepository,
            moviesQueriesRepository: moviesQueriesRepository
        )

        // when
        let requestValue = SearchMoviesUseCaseRequestValue(
            query: MovieQuery(query: "title1"),
            page: 0
        )
        _ = useCase.execute(
            requestValue: requestValue,
            cached: { _ in }
        ) { _ in
            useCaseCompletionCallsCount += 1
        }
        // then
        var recents = [MovieQuery]()
        moviesQueriesRepository.fetchRecentsQueries(maxCount: 1) { result in
            recents = (try? result.get()) ?? []
        }
        XCTAssertTrue(recents.contains(MovieQuery(query: "title1")))
        XCTAssertEqual(useCaseCompletionCallsCount, 1)
        XCTAssertEqual(moviesQueriesRepository.fetchCompletionCallsCount, 1)
        XCTAssertEqual(moviesRepository.fetchCompletionCallsCount, 1)
    }
    
    func testSearchMoviesUseCase_whenFailedFetchingMoviesForQuery_thenQueryIsNotSavedInRecentQueries() {
        // given
        var useCaseCompletionCallsCountCount = 0
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let useCase = DefaultSearchMoviesUseCase(moviesRepository: MoviesRepositoryMock(result: .failure(MoviesRepositorySuccessTestError.failedFetching)),
                                                 moviesQueriesRepository: moviesQueriesRepository)
        
        // when
        let requestValue = SearchMoviesUseCaseRequestValue(query: MovieQuery(query: "title1"),
                                                           page: 0)
        _ = useCase.execute(requestValue: requestValue, cached: { _ in }) { _ in
            useCaseCompletionCallsCountCount += 1
        }
        // then
        var recents = [MovieQuery]()
        moviesQueriesRepository.fetchRecentsQueries(maxCount: 1) { result in
            recents = (try? result.get()) ?? []
        }
        XCTAssertTrue(recents.isEmpty)
        XCTAssertEqual(useCaseCompletionCallsCountCount, 1)
        XCTAssertEqual(moviesQueriesRepository.fetchCompletionCallsCount, 1)
    }
}
