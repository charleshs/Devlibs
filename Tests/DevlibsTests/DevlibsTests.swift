import XCTest
@testable import Devlibs

final class DevlibsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Devlibs().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
