import Foundation

struct MoviesListViewModelActions {
    let showMovieDetails: (Movie) -> Void
    let showMovieQueriesSuggestions: (@escaping (_ didSelect: MovieQuery) -> Void) -> Void
    let closeMovieQueriesSuggestions: () -> Void
}

enum MoviesListViewModelLoadMode {
    case trending
    case search
}

enum MoviesListViewModelLoading {
    case fullScreen
    case nextPage
}

protocol MoviesListViewModelInput {
    func viewDidLoad()
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func showQueriesSuggestions()
    func closeQueriesSuggestions()
    func didSelectItem(at index: Int)
}

protocol MoviesListViewModelOutput {
    var items: Observable<[MoviesListItemViewModel]> { get }
    var loading: Observable<MoviesListViewModelLoading?> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
}

typealias MoviesListViewModel = MoviesListViewModelInput & MoviesListViewModelOutput

final class DefaultMoviesListViewModel: MoviesListViewModel {
    
    private let trendingMoviesUseCase: TrendingMoviesUseCase
    private let searchMoviesUseCase: SearchMoviesUseCase
    private let actions: MoviesListViewModelActions?
    
    var loadMode: MoviesListViewModelLoadMode = .trending
    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }
    
    private var pages: [MoviesPage] = []
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    private let mainQueue: DispatchQueueType
    
    // MARK: - OUTPUT
    
    let items: Observable<[MoviesListItemViewModel]> = Observable([])
    let loading: Observable<MoviesListViewModelLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = NSLocalizedString("Movies", comment: "")
    let emptyDataTitle = NSLocalizedString("No movie :(", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder = NSLocalizedString("Search Movies", comment: "")
    
    // MARK: - Init
    
    init(
        trendingMoviesUseCase: TrendingMoviesUseCase,
        searchMoviesUseCase: SearchMoviesUseCase,
        actions: MoviesListViewModelActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.trendingMoviesUseCase = trendingMoviesUseCase
        self.searchMoviesUseCase = searchMoviesUseCase
        self.actions = actions
        self.mainQueue = mainQueue
    }
    
    // MARK: - Private
    
    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages
        
        pages = pages
            .filter { $0.page != moviesPage.page }
        + [moviesPage]
        
        items.value = pages.movies.map(MoviesListItemViewModel.init)
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.value.removeAll()
    }
    
    private func loadTrendingMovies(_ loading: MoviesListViewModelLoading) {
        self.loading.value = loading
        
        moviesLoadTask = trendingMoviesUseCase.execute(
            requestValue: .init(timeWindow: "day", page: nextPage),
            cached: { [weak self] page in
                self?.mainQueue.async {
                    self?.appendPage(page)
                }
            },
            completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handle(error: error)
                    }
                    self?.loading.value = .none
                }
            })
    }
    
    private func load(movieQuery: MovieQuery, loading: MoviesListViewModelLoading) {
        self.loading.value = loading
        query.value = movieQuery.query
        
        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: .init(query: movieQuery, page: nextPage),
            cached: { [weak self] page in
                self?.mainQueue.async {
                    self?.appendPage(page)
                }
            },
            completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handle(error: error)
                    }
                    self?.loading.value = .none
                }
            })
    }
    
    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
        NSLocalizedString("No internet connection", comment: "") :
        NSLocalizedString("Failed loading movies", comment: "")
    }
    
    private func loadTrendingMovies() {
        resetPages()
        self.loadMode = .trending
        loadTrendingMovies(.fullScreen)
    }
    
    private func update(movieQuery: MovieQuery) {
        resetPages()
        self.loadMode = .search
        load(movieQuery: movieQuery, loading: .fullScreen)
    }
}

// MARK: - INPUT. View event methods

extension DefaultMoviesListViewModel {
    
    func viewDidLoad() {
        loadTrendingMovies()
    }
    
    func didLoadNextPage() {
        guard hasMorePages, loading.value == .none else { return }
        switch loadMode {
        case .search:
            load(movieQuery: .init(query: query.value),
                 loading: .nextPage)
        case .trending:
            loadTrendingMovies(.nextPage)
        }
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else {
            loadTrendingMovies()
            return
        }
        update(movieQuery: MovieQuery(query: query))
    }
    
    func didCancelSearch() {
        loadTrendingMovies()
    }
    
    func showQueriesSuggestions() {
        actions?.showMovieQueriesSuggestions(update(movieQuery:))
    }
    
    func closeQueriesSuggestions() {
        actions?.closeMovieQueriesSuggestions()
    }
    
    func didSelectItem(at index: Int) {
        actions?.showMovieDetails(pages.movies[index])
    }
}

// MARK: - Private

private extension Array where Element == MoviesPage {
    var movies: [Movie] { flatMap { $0.movies } }
}
