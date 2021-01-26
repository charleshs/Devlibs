import XCTest
@testable import Devlibs

final class CallbackQueueTests: XCTestCase {
    func testDispatchAsyncOnMainQueue() {
        let promise = expectation(description: "mainAsync")
        DispatchQueue.global().async {
            XCTAssert(!Thread.isMainThread)
            CallbackQueue.mainAsync.execute {
                XCTAssert(Thread.isMainThread)
                promise.fulfill()
            }
        }
        wait(for: [promise], timeout: 1)
    }

    func testExecuteOnMainThreadOtherwiseDispatchAsync() {
        var flag = false
        CallbackQueue.mainOtherwiseAsync.execute {
            flag = true
        }
        XCTAssertTrue(flag)

        let promise = expectation(description: "mainOtherwiseAsync")
        DispatchQueue.global().async {
            CallbackQueue.mainOtherwiseAsync.execute {
                XCTAssert(Thread.isMainThread)
                promise.fulfill()
            }
        }
        wait(for: [promise], timeout: 1)
    }

    func testExecuteOnOriginalDispatchQueue() {
        let testQueue = DispatchQueue(label: "TestQueue", qos: .userInitiated)
        let key = DispatchSpecificKey<Void>()
        testQueue.setSpecific(key: key, value: ())

        let promise = expectation(description: "untouched")
        testQueue.async {
            CallbackQueue.untouched.execute {
                XCTAssertNotNil(DispatchQueue.getSpecific(key: key))
                promise.fulfill()
            }
        }
        wait(for: [promise], timeout: 1)
    }

    func testDispatchOnSpecificDispatchQueue() {
        let testQueue = DispatchQueue(label: "TestQueue", qos: .userInitiated)
        let key = DispatchSpecificKey<Void>()
        testQueue.setSpecific(key: key, value: ())

        let promise = expectation(description: "dispatch")
        DispatchQueue.global().async {
            CallbackQueue.dispatched(on: testQueue).execute {
                XCTAssertNotNil(DispatchQueue.getSpecific(key: key))
                promise.fulfill()
            }
        }
        wait(for: [promise], timeout: 1)
    }
}
