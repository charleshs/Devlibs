#if canImport(Combine) && (os(iOS) || os(tvOS))
import Combine
import Foundation
import UIKit.UIControl

@available(iOS 13.0, tvOS 13.0, *)
extension Combine.Publishers {
    public struct ControlProperty<Control: UIControl, Value>: Publisher {
        public typealias Output = Value
        public typealias Failure = Never

        private let control: Control
        private let controlEvents: Control.Event
        private let keyPath: KeyPath<Control, Value>

        public init(control: Control, events: Control.Event, keyPath: KeyPath<Control, Value>) {
            self.control = control
            self.controlEvents = events
            self.keyPath = keyPath
        }

        public func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = Subscription(subscriber: subscriber, control: control, events: controlEvents, keyPath: keyPath)
            subscriber.receive(subscription: subscription)
        }
    }
}

@available(iOS 13.0, tvOS 13.0, *)
extension Combine.Publishers.ControlProperty {
    private final class Subscription<S: Subscriber, Control: UIControl, Value>: Combine.Subscription where S.Input == Value {
        private var subscriber: S?
        private weak var control: Control?
        private let events: Control.Event
        private let keyPath: KeyPath<Control, Value>
        private var didEmitInitial = false

        init(subscriber: S, control: Control, events: Control.Event, keyPath: KeyPath<Control, Value>) {
            self.subscriber = subscriber
            self.control = control
            self.events = events
            self.keyPath = keyPath
            control.addTarget(self, action: #selector(handleEvent), for: events)
        }

        func request(_ demand: Subscribers.Demand) {
            // Emits initial value upon first demand request
            guard didEmitInitial,
                  demand > .none,
                  let control = control,
                  let subscriber = subscriber
            else { return }

            _ = subscriber.receive(control[keyPath: keyPath])
            didEmitInitial = true
        }

        func cancel() {
            subscriber = nil
        }

        @objc
        private func handleEvent() {
            guard let control = control else { return }
            _ = subscriber?.receive(control[keyPath: keyPath])
        }
    }
}

extension UIControl.Event {
    static var valueEvents: UIControl.Event {
        return [.allEditingEvents, valueChanged]
    }
}
#endif
