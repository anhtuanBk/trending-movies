import XCTest

class MoviesSceneUITests: XCTestCase {

    override func setUp() {

        continueAfterFailure = false
        XCUIApplication().launch()
    }

    // NOTE: for UI tests to work the keyboard of simulator must be on.
    // Keyboard shortcut COMMAND + SHIFT + K while simulator has focus
    
    func testLoadTrendingMovies_whenMovieListScreenFirstLoad_thenShowTodayTrendingMoviesOrEmpty() {
        let app = XCUIApplication()
        let count = app.tables.count
        let emptyLabel = app.staticTexts[AccessibilityIdentifier.emptyLabel]
        XCTAssertTrue((count > 0 && !emptyLabel.exists) || (count < 1 && emptyLabel.exists))
    }
    
    func testOpenMovieDetails_whenSearchDuneAndTapOnFirstResultRow_thenMovieDetailsViewOpensWithTitleDune() {
        
        let app = XCUIApplication()
        
        // Search for Dune
        let searchText = "Dune"
        app.searchFields[AccessibilityIdentifier.searchField].tap()
        if !app.keys["A"].waitForExistence(timeout: 5) {
            XCTFail("The keyboard could not be found. Use keyboard shortcut COMMAND + SHIFT + K while simulator has focus on text input")
        }
        _ = app.searchFields[AccessibilityIdentifier.searchField].waitForExistence(timeout: 10)
        app.searchFields[AccessibilityIdentifier.searchField].typeText(searchText)
        app.buttons["search"].tap()
        
        // Tap on first result row
        app.tables.cells.staticTexts[searchText].firstMatch.tap()
        
        // Make sure movie details view
        XCTAssertTrue(app.otherElements[AccessibilityIdentifier.movieDetailsView].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars[searchText].waitForExistence(timeout: 5))
    }
}
