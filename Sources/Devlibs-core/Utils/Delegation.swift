/// A wrapper of a closure that keeps a weak reference to the target object,
/// avoiding retain-cycles caused by strongly referencing the object in the closure.
public final class Delegation<Input, Output> {
    private var closure: ((Input) -> Output?)?

    private init() {}

    public static func create<Target: AnyObject>(
        on target: Target,
        closure: @escaping (Target, Input) -> Output
    ) -> Delegation<Input, Output> {
        let handler = Delegation<Input, Output>()
        handler.delegate(on: target, closure: closure)
        return handler
    }

    @discardableResult
    public func invoke(_ input: Input) -> Output? {
        return closure?(input)
    }

    @discardableResult
    public func callAsFunction(_ input: Input) -> Output? {
        return invoke(input)
    }

    private func delegate<T: AnyObject>(on target: T, closure: @escaping (T, Input) -> Output) {
        self.closure = { [weak target] input in
            guard let target = target else {
                return nil
            }
            return closure(target, input)
        }
    }
}

extension Delegation where Input == Void {
    @discardableResult
    public func invoke() -> Output? {
        return invoke(())
    }

    @discardableResult
    public func callAsFunction() -> Output? {
        return invoke()
    }
}
