import Foundation

public protocol Logging {
    associatedtype Info: LoggingInfo
    static func log(_ item: Any, _ info: Info)
}

public protocol LoggingInfo {
    var description: String { get }
}

public struct Logger: Logging {
    public struct Info: LoggingInfo {
        public enum Level {
            case log
            case debug
            case release
            case error
            case fault
        }
        
        public var description: String {
            return "<<<\(functionName) @ \(fileId)-line:\(lineNumber)>>>"
        }

        let level: Level
        private let functionName: String
        private let fileId: String
        private let lineNumber: Int
        
        public init(_ level: Level, functionName: String = #function, fileId: String = #fileID, lineNumber: Int = #line) {
            self.level = level
            self.functionName = functionName
            self.fileId = fileId
            self.lineNumber = lineNumber
        }
    }
    
    public static func log(_ item: Any, _ info: Info = .init(.log)) {
        var verboseMessage: String
        switch item {
        case let customDebug as CustomDebugStringConvertible: verboseMessage = customDebug.debugDescription
        case let custom as CustomStringConvertible: verboseMessage = custom.description
        default: verboseMessage = String(describing: item)
        }
        verboseMessage += " \(info.description)"

        switch info.level {
        case .log:
            print(item)
        case .debug:
            print(verboseMessage)
        case .release:
            print(verboseMessage)
        case .error:
            print("@Error@ \(verboseMessage)")
        case .fault:
            print("@Fault@ \(verboseMessage)")
        }
    }
}
