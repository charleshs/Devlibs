#if canImport(Combine) && (os(iOS) || os(tvOS))
import Combine
import UIKit

@available(iOS 13.0, tvOS 13.0, *)
extension UIGestureRecognizer {
    public var publisher: AnyPublisher<UIGestureRecognizer, Never> {
        Publishers.TargetAction<UIGestureRecognizer>(
            control: self,
            addTargetAction: { gestureRecognizer, target, action in
                gestureRecognizer.addTarget(target, action: action)
            },
            removeTargetAction: { gestureRecognizer, target, action in
                gestureRecognizer?.removeTarget(target, action: action)
            }
        )
        .eraseToAnyPublisher()
    }

    public func assign(
        to view: UIView,
        storedIn cancellables: inout Set<AnyCancellable>,
        action: @escaping () -> Void
    ) {
        publisher
            .sink { _ in action() }
            .store(in: &cancellables)
        view.addGestureRecognizer(self)
    }
}
#endif
