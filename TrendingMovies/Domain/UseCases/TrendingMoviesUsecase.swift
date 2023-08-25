import Foundation

protocol TrendingMoviesUseCase {
    func execute(
        requestValue: TrendingMoviesUseCaseRequestValue,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultTrendingMoviesUseCase: TrendingMoviesUseCase {
    
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func execute(
        requestValue: TrendingMoviesUseCaseRequestValue,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        
        return moviesRepository.fetchTrendingMoviesList(
            timeWindow: requestValue.timeWindow,
            page: requestValue.page,
            cached: cached,
            completion: { result in
                completion(result)
            })
    }
}

struct TrendingMoviesUseCaseRequestValue {
    let timeWindow: String
    let page: Int
}
