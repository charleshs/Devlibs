#if canImport(Combine) && (os(iOS) || os(tvOS))
import Combine
import Foundation

@available(iOS 13.0, tvOS 13.0, *)
extension Combine.Publishers {
    public struct TargetAction<Control: AnyObject>: Publisher {
        public typealias Output = Control
        public typealias Failure = Never

        private let control: Control
        private let addTargetAction: (Control, AnyObject, Selector) -> Void
        private let removeTargetAction: (Control?, AnyObject, Selector) -> Void

        public init(
            control: Control,
            addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
            removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void
        ) {
            self.control = control
            self.addTargetAction = addTargetAction
            self.removeTargetAction = removeTargetAction
        }

        public func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = Subscription(
                subscriber: subscriber,
                control: control,
                addTargetAction: addTargetAction,
                removeTargetAction: removeTargetAction
            )
            subscriber.receive(subscription: subscription)
        }
    }
}

@available(iOS 13.0, tvOS 13.0, *)
extension Combine.Publishers.TargetAction {
    private final class Subscription<S: Subscriber, Control: AnyObject>: Combine.Subscription where S.Input == Control {
        private var subscriber: S?
        private weak var control: Control?

        private let removeTargetAction: (Control?, AnyObject, Selector) -> Void
        private let action = #selector(handleEvent)

        init(
            subscriber: S,
            control: Control,
            addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
            removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void
        ) {
            self.subscriber = subscriber
            self.control = control
            self.removeTargetAction = removeTargetAction

            addTargetAction(control, self, action)
        }

        func request(_ demand: Subscribers.Demand) {
            // We don't care about the demand at this point.
            // As far as we're concerned - The control's target events are endless until it is deallocated.
        }

        func cancel() {
            removeTargetAction(control, self, action)
            subscriber = nil
        }

        @objc
        private func handleEvent() {
            guard let control = control else { return }
            _ = subscriber?.receive(control)
        }
    }
}
#endif
