#if canImport(Combine) && (os(iOS))
import Combine
import UIKit

@available(iOS 13.0, tvOS 13.0, *)
extension UISwitch {
    /// A publisher emitting on status changes for this switch.
    public var isOnPublisher: AnyPublisher<Bool, Never> {
        Publishers.ControlProperty<UISwitch, Bool>(control: self, events: .valueEvents, keyPath: \.isOn)
            .eraseToAnyPublisher()
    }

    @discardableResult
    public func onStatusChanged(
        storedIn cancellables: inout Set<AnyCancellable>,
        action: @escaping (Bool) -> Void
    ) -> Self {
        isOnPublisher
            .sink(receiveValue: { isOn in action(isOn) })
            .store(in: &cancellables)
        return self
    }
}
#endif
