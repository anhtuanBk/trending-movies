import Foundation

protocol MoviesRepository {
    @discardableResult
    func fetchTrendingMoviesList(
        timeWindow: String,
        page: Int,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
    
    @discardableResult
    func fetchSearchMoviesList(
        query: MovieQuery,
        page: Int,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}
