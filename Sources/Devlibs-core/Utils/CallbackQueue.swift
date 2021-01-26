import Foundation

public enum CallbackQueue {
    case mainAsync
    case mainOtherwiseAsync
    case untouched
    case dispatched(on: DispatchQueue)

    public func execute(_ runTask: @escaping () -> Void) {
        switch self {
        case .mainAsync:
            DispatchQueue.main.async { runTask() }
        case .mainOtherwiseAsync:
            DispatchQueue.main.asyncSafe { runTask() }
        case .untouched:
            runTask()
        case .dispatched(let queue):
            queue.async { runTask() }
        }
    }
}

extension DispatchQueue {
    func asyncSafe(execute runTask: @escaping () -> Void) {
        guard Thread.isMainThread, DispatchQueue.main === self else {
            return DispatchQueue.main.async { runTask() }
        }
        runTask()
    }
}
