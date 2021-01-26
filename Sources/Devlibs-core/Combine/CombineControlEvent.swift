#if canImport(Combine) && (os(iOS) || os(tvOS))
import Combine
import Foundation
import UIKit.UIControl

@available(iOS 13.0, tvOS 13.0, *)
extension Combine.Publishers {
    /// A publisher that emits whenever the provided events fire.
    public struct ControlEvent<Control: UIControl>: Publisher {
        public typealias Output = Control
        public typealias Failure = Never

        private let control: Control
        private let events: Control.Event

        public init(control: Control, events: Control.Event) {
            self.control = control
            self.events = events
        }

        public func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = Subscription(subscriber: subscriber, control: control, events: events)
            subscriber.receive(subscription: subscription)
        }
    }
}

@available(iOS 13.0, tvOS 13.0, *)
extension Combine.Publishers.ControlEvent {
    private final class Subscription<S: Subscriber, Control: UIControl>: Combine.Subscription where S.Input == Control {
        private var subscriber: S?
        private weak var control: Control?

        init(subscriber: S, control: Control, events: Control.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(handleEvent), for: events)
        }

        func request(_ demand: Subscribers.Demand) {
            // We don't care about the demand at this point.
            // As far as we're concerned - UIControl events are endless until the control is deallocated.
        }

        func cancel() {
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
