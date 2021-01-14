import Devlibs
import XCTest

final class DelegationTests: XCTestCase {
    private var target: Target?

    override func setUpWithError() throws {
        target = Target(flag: false)
    }

    func testInvokeBehavior() {
        let promise = expectation(description: "closure-invoked")
        let delegation = Delegation<Bool, Int>.create(on: target!) { target, input in
            target.flag = input
            promise.fulfill()
            return 1
        }

        let output = delegation.invoke(true)

        XCTAssertNotNil(output)
        XCTAssertEqual(target?.flag, true)
        wait(for: [promise], timeout: 1)
    }

    func testCallAsFunction() {
        let promise = expectation(description: "closure-invoked")
        let delegation = Delegation<Bool, Int>.create(on: target!) { target, input in
            target.flag = input
            promise.fulfill()
            return 1
        }

        let output = delegation(true)

        XCTAssertNotNil(output)
        XCTAssertEqual(target?.flag, true)
        wait(for: [promise], timeout: 1)
    }

    func testWeakReference() {
        let delegation = Delegation<Bool, Int>.create(on: target!) { target, input in
            XCTFail("Closure should not be executed")
            target.flag = input
            return 1
        }

        // Subtract target's ARC by 1.
        target = nil
        let output = delegation.invoke(true)

        XCTAssertNil(output)
    }
}

private final class Target {
    var flag: Bool

    init(flag: Bool) {
        self.flag = flag
    }
}
