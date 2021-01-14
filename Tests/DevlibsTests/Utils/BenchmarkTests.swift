import XCTest
@testable import Devlibs

final class BenchmarkTests: XCTestCase {
    func testNumberOfSamples() {
        let targetNumberOfSamples: Int = 1000
        var setupExecutionTimes: Int = .zero
        var actionExecutionTimes: Int = .zero

        Benchmark.measure(
            label: nil,
            numberOfSamples: targetNumberOfSamples,
            printsResult: false,
            setup: {
                setupExecutionTimes += 1
            },
            action: {
                actionExecutionTimes += 1
            }
        )

        XCTAssertEqual(setupExecutionTimes, targetNumberOfSamples)
        XCTAssertEqual(actionExecutionTimes, targetNumberOfSamples)
    }

    func testExecutionOrderForSetupAndAction() {
        var setupInvokedFlag: Bool = false
        var actionInvokedFlag: Bool = false

        Benchmark.measure(
            numberOfSamples: 1,
            setup: {
                setupInvokedFlag = true
            },
            action: {
                XCTAssertTrue(setupInvokedFlag)
                XCTAssertFalse(actionInvokedFlag)
                actionInvokedFlag = true
            }
        )

        XCTAssertTrue(actionInvokedFlag)
    }

    func testMeasureBehavior() {
        var array: [Int] = Array(0 ..< 10000)
        let title: String = "sorting array containing 10000 elements"

        let timeElapsed = Benchmark.measure(
            label: title,
            numberOfSamples: 50,
            printsResult: true,
            setup: {
                array.shuffle()
            },
            action: {
                array.sort()
            }
        )

        XCTAssertTrue(timeElapsed > 0)

        let timeInMilliSeconds = String(format: "%.4f", timeElapsed * 1000)
        let description = "@#$% The average elapsed time for \(title) is \(timeInMilliSeconds) ms"
        print(description)
    }
}
