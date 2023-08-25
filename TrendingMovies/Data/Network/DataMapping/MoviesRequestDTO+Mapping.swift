import Foundation

struct MoviesRequestDTO: Encodable {
    let timeWindow: String
    let query: String
    let page: Int
}
