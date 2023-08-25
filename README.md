
# Trending Movies App

iOS app showing trending movies on The Movies DB, implemented with Clean Layered Architecture and MVVM


![Alt text](README_FILES/CleanArchitecture+MVVM.png?raw=true "Clean Architecture Layers")

## Layers
* **Domain Layer** = Entities + Use Cases + Repositories Interfaces
* **Data Repositories Layer** = Repositories Implementations + API (Network) + Persistence DB
* **Presentation Layer (MVVM)** = ViewModels + Views

### Dependency Direction
![Alt text](README_FILES/CleanArchitectureDependencies.png?raw=true "Modules Dependencies")

**Note:** **Domain Layer** should not include anything from other layers(e.g Presentation — UIKit or SwiftUI or Data Layer — Mapping Codable)

## Architecture concepts used here
* Clean Architecture https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
* Advanced iOS App Architecture https://www.raywenderlich.com/8477-introducing-advanced-ios-app-architecture
* [MVVM](TrendingMovies/Presentation/MoviesScene/MoviesQueriesList) 
* Data Binding using [Observable](TrendingMovies/Presentation/Utils/Observable.swift) without 3rd party libraries 
* [Dependency Injection](TrendingMovies/Application/DIContainer/AppDIContainer.swift)
* [Flow Coordinator](TrendingMovies/Presentation/MoviesScene/Flows/MoviesFlowCoordinator.swift)
* [Data Transfer Object (DTO)](TrendingMovies/Data/Network/DataMapping/MoviesResponseDTO%2BMapping.swift)
* [Response Data Caching](TrendingMovies/Data/Repositories/DefaultMoviesRepository.swift)
* [ViewController Lifecycle Behavior](TrendingMovies/Presentation/Utils/Extensions/UIViewController%2BAddBehaviors.swift#L7)
* [SwiftUI and UIKit view](TrendingMovies/Presentation/MoviesScene/MoviesQueriesList/View/SwiftUI/MoviesQueryListView.swift) implementations by reusing same [ViewModel](TrendingMovies/Presentation/MoviesScene/MoviesQueriesList/ViewModel/MoviesQueryListViewModel.swift) (at least Xcode 11 required)
* Error handling: in [ViewModel](TrendingMovies/Presentation/MoviesScene/MoviesList/ViewModel/MoviesListViewModel.swift#L116), in [Networking](TrendingMovies/Infrastructure/Network/NetworkService.swift#L84)
* CI Pipeline ([Travis CI + Fastlane](.travis.yml))
 
## Includes
* Trending movies with infinite scroll and offline-first support
* Movies search with infinite scroll and offline recent queries
* Movie detail page with offline-first support
* Error and empty handling
* Unit Tests for Use Cases(Domain Layer), ViewModels(Presentation Layer), NetworkService(Infrastructure Layer)
* UI Tests for showing trending movies and movie searching
* SwiftUI example, demostration that presentation layer does not change, only UI (at least Xcode 11 required)

## Requirements
* Xcode Version 11.2.1+  Swift 5.0+

