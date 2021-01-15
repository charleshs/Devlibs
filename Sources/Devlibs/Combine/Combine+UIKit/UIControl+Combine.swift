#if canImport(Combine) && (os(iOS) || os(tvOS))
import Combine
import UIKit

@available(iOS 13.0, tvOS 13.0, *)
extension UIControl {
    public func controlEventPublisher(for events: UIControl.Event) -> AnyPublisher<UIControl, Never> {
        Publishers.ControlEvent<UIControl>(control: self, events: events)
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    public func onEvents(
        _ events: UIControl.Event,
        storedIn cancellables: inout Set<AnyCancellable>,
        action: @escaping () -> Void
    ) -> Self {
        controlEventPublisher(for: events)
            .sink { _ in action() }
            .store(in: &cancellables)
        return self
    }
}
#endif
