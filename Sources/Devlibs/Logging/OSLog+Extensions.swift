import os.log

extension OSLog {
    /// Logs a message with the `debug` log level.
    /// - Parameters:
    ///   - message: A constant string or format string that produces a human-readable log message.
    ///   - args: If message is a constant string, do not specify arguments.
    ///           If message is a format string, pass the expected number of arguments in the appearing order.
    /// - A known issue: In `Console.app`, logs at `debug` level generated from the simulator can't be seen.
    public func debug(_ message: StaticString, _ args: CVarArg...) {
        logMessage(message, type: .debug, args)
    }

    /// Logs a message with the `default` log level.
    /// - Parameters:
    ///   - message: A constant string or format string that produces a human-readable log message.
    ///   - args: If message is a constant string, do not specify arguments.
    ///           If message is a format string, pass the expected number of arguments in the appearing order.
    public func `default`(_ message: StaticString, _ args: CVarArg...) {
        logMessage(message, type: .default, args)
    }

    /// Logs a message with the `info` log level.
    /// - Parameters:
    ///   - message: A constant string or format string that produces a human-readable log message.
    ///   - args: If message is a constant string, do not specify arguments.
    ///           If message is a format string, pass the expected number of arguments in the appearing order.
    public func info(_ message: StaticString, _ args: CVarArg...) {
        logMessage(message, type: .info, args)
    }

    /// Logs a message with the `error` log level.
    /// - Parameters:
    ///   - message: A constant string or format string that produces a human-readable log message.
    ///   - args: If message is a constant string, do not specify arguments.
    ///           If message is a format string, pass the expected number of arguments in the appearing order.
    public func error(_ message: StaticString, _ args: CVarArg...) {
        logMessage(message, type: .error, args)
    }

    /// Logs a message with the `fault` log level.
    /// - Parameters:
    ///   - message: A constant string or format string that produces a human-readable log message.
    ///   - args: If message is a constant string, do not specify arguments.
    ///           If message is a format string, pass the expected number of arguments in the appearing order.
    public func fault(_ message: StaticString, _ args: CVarArg...) {
        logMessage(message, type: .fault, args)
    }

    private func logMessage(_ message: StaticString, type: OSLogType, _ args: [CVarArg]) {
        switch args.count {
        case 0:
            os_log(message, log: self, type: type)
        case 1:
            os_log(message, log: self, type: type, args[0])
        case 2:
            os_log(message, log: self, type: type, args[0], args[1])
        case 3:
            os_log(message, log: self, type: type, args[0], args[1], args[2])
        case 4:
            os_log(message, log: self, type: type, args[0], args[1], args[2], args[3])
        case 5:
            os_log(message, log: self, type: type, args[0], args[1], args[2], args[3], args[4])
        default:
            assertionFailure("Too many arguments passed to \(#function). Update this to support more arguments.")
            os_log(message, log: self, type: type, args[0], args[1], args[2], args[3], args[4], args[5])
        }
    }
}
