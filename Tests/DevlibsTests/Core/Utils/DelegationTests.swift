import XCTest
@testable import Devlibs

final class DelegationTests: XCTestCase {
    private var target: Target?

    override func setUpWithError() throws {
        target = Target(flag: false)
    }

    func testInvokeBehavior() {
        let promise = expectation(description: "closure-invoked")
        let handler = Delegation<Bool, Int>.create(on: target!) { target, input in
            target.flag = input
            promise.fulfill()
            return 1
        }

        let output = handler.invoke(true)

        XCTAssertNotNil(output)
        XCTAssertEqual(target?.flag, true)
        wait(for: [promise], timeout: 1)
    }

    func testCallAsFunction() {
        let promise = expectation(description: "closure-invoked")
        let handler = Delegation<Bool, Int>.create(on: target!) { target, input in
            target.flag = input
            promise.fulfill()
            return 1
        }

        let output = handler(true)

        XCTAssertNotNil(output)
        XCTAssertEqual(target?.flag, true)
        wait(for: [promise], timeout: 1)
    }

    func testWeakReference() {
        let handler = Delegation<Bool, Int>.create(on: target!) { target, input in
            XCTFail("Closure should not be executed")
            target.flag = input
            return 1
        }

        // Subtract target's ARC by 1.
        target = nil
        let output = handler.invoke(true)

        XCTAssertNil(output)
    }
}

private final class Target {
    var flag: Bool

    init(flag: Bool) {
        self.flag = flag
    }
}
