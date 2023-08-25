import Foundation

extension Movie {
    static func stub(id: Movie.Identifier = "id1",
                     title: String = "title1" ,
                     genre: Movie.Genre = .adventure,
                     posterPath: String? = "/1",
                     overview: String = "overview1",
                     releaseDate: Date? = nil,
                     voteAverage: Double? = nil) -> Self {
        Movie(id: id,
              title: title,
              genre: genre,
              posterPath: posterPath,
              overview: overview,
              releaseDate: releaseDate,
              voteAverage: voteAverage)
    }
}
