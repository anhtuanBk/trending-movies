import Foundation

struct APIEndpoints {
    
    static func getTrendingMovies(with moviesRequestDTO: MoviesRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/trending/movie",
            method: .get,
            pathParameters: [moviesRequestDTO.timeWindow],
            queryParameters: ["page": moviesRequestDTO.page]
        )
    }
    
    static func searchMovies(with moviesRequestDTO: MoviesRequestDTO) -> Endpoint<MoviesResponseDTO> {

        return Endpoint(
            path: "3/search/movie",
            method: .get,
            queryParameters: [
                "query": moviesRequestDTO.query,
                "page": moviesRequestDTO.page
            ]
        )
    }

    static func getMoviePoster(path: String, width: Int) -> Endpoint<Data> {

        let sizes = [92, 154, 185, 342, 500, 780]
        let closestWidth = sizes
            .enumerated()
            .min { abs($0.1 - width) < abs($1.1 - width) }?
            .element ?? sizes.first!
        
        return Endpoint(
            path: "t/p/w\(closestWidth)\(path)",
            method: .get,
            responseDecoder: RawDataResponseDecoder()
        )
    }
}
