import Foundation

enum MoviesRepositorySuccessTestError: Error {
    case failedFetching
}

class MoviesQueriesRepositoryMock: MoviesQueriesRepository {
    var recentQueries: [MovieQuery] = []
    var fetchCompletionCallsCount = 0
    
    func fetchRecentsQueries(
        maxCount: Int,
        completion: @escaping (Result<[MovieQuery], Error>) -> Void
    ) {
        completion(.success(recentQueries))
        fetchCompletionCallsCount += 1
    }
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {
        recentQueries.append(query)
    }
}

class MoviesRepositoryMock: MoviesRepository {
    var result: Result<MoviesPage, Error>
    var fetchCompletionCallsCount = 0

    init(result: Result<MoviesPage, Error>) {
        self.result = result
    }
    
    func fetchTrendingMoviesList(
        timeWindow: String,
        page: Int,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>
        ) -> Void
    ) -> Cancellable? {
        completion(result)
        fetchCompletionCallsCount += 1
        return nil
    }

    func fetchSearchMoviesList(
        query: MovieQuery,
        page: Int,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>
        ) -> Void
    ) -> Cancellable? {
        completion(result)
        fetchCompletionCallsCount += 1
        return nil
    }
}
