#if canImport(Combine) && (os(iOS) || os(tvOS))
import Combine
import UIKit

@available(iOS 13.0, tvOS 13.0, *)
extension UIButton {
    public var tapPublisher: AnyPublisher<UIButton, Never> {
        controlEventPublisher(for: .touchUpInside)
            .map { $0 as! UIButton }
            .eraseToAnyPublisher()
    }

    @discardableResult
    public func onTapped(
        storedIn cancellables: inout Set<AnyCancellable>,
        action: @escaping () -> Void
    ) -> Self {
        tapPublisher
            .sink(receiveValue: { _ in action() })
            .store(in: &cancellables)
        return self
    }
}
#endif
