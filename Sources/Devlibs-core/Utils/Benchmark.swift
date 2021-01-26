import Foundation

/// A struct providing benchmarking functionality.
public struct Benchmark {
    /// Measures the execution time of an operation.
    /// - Parameters:
    ///     - label: The label for the measurement. It'll be displayed as title in printed outputs (if `printsResult` is true).
    ///     - numberOfSamples: The times for which the operation will be repeated.
    ///     - printsResult: A boolean indicating whether to print the result of the current measurement.
    ///     - setup: A setup closure executed before the `action` in each run of measurement.
    ///     - action: The operation being measured.
    /// - Returns: The average execution time (in seconds) of the `action` operation.
    @discardableResult
    public static func measure(
        label: String? = nil,
        numberOfSamples: Int = 1,
        printsResult: Bool = true,
        setup: @escaping () -> Void = {},
        action: @escaping () -> Void
    ) -> CFAbsoluteTime {
        guard numberOfSamples > 0 else {
            fatalError("Number of tests must be greater than 0")
        }

        var averageExecutionTime: CFAbsoluteTime = 0
        for _ in 1...numberOfSamples {
            setup()
            let start = CFAbsoluteTimeGetCurrent()
            action()
            let end = CFAbsoluteTimeGetCurrent()
            averageExecutionTime += end - start
        }
        averageExecutionTime /= CFAbsoluteTime(numberOfSamples)

        if printsResult {
            printResult(label: label, executionTime: averageExecutionTime, numberOfSamples: numberOfSamples)
        }

        return averageExecutionTime
    }

    private static func printResult(label: String? = nil, executionTime: CFAbsoluteTime, numberOfSamples: Int) {
        let timeString = String(executionTime)
            .replacingOccurrences(of: "e|E", with: " × 10^", options: .regularExpression, range: nil)

        let outputText = [
            label.map { ">>> Benchmark: \($0)" } ?? ">>> Starts measurements",
            "\tExecution time: \(timeString)",
            "\tNumber of samples: \(numberOfSamples)",
            ">>> Ended measurements",
        ]
        .joined(separator: "\n")

        print(outputText)
    }
}
