#if canImport(Combine) && (os(iOS) || os(tvOS))
import Combine
import UIKit

@available(iOS 13.0, tvOS 13.0, *)
extension UIBarButtonItem {
    public var tapPublisher: AnyPublisher<UIBarButtonItem, Never> {
        Publishers.TargetAction<UIBarButtonItem>(
            control: self,
            addTargetAction: { barButtonItem, target, selector in
                barButtonItem.target = target
                barButtonItem.action = selector
            },
            removeTargetAction: { barButtonItem, _, selector in
                barButtonItem?.target = nil
                barButtonItem?.action = nil
            }
        )
        .eraseToAnyPublisher()
    }

    @discardableResult
    public func onTapped(
        storedIn cancellables: inout Set<AnyCancellable>,
        action: @escaping () -> Void
    ) -> Self {
        tapPublisher
            .sink { _ in action() }
            .store(in: &cancellables)
        return self
    }

    public convenience init(
        image: UIImage?,
        style: UIBarButtonItem.Style,
        cancellables: inout Set<AnyCancellable>,
        action: @escaping () -> Void
    ) {
        self.init(image: image, style: style, target: nil, action: nil)
        tapPublisher
            .sink { _ in action() }
            .store(in: &cancellables)
    }

    public convenience init(
        image: UIImage?,
        landscapeImagePhone: UIImage?,
        style: UIBarButtonItem.Style,
        cancellables: inout Set<AnyCancellable>,
        action: @escaping () -> Void
    ) {
        self.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: nil)
        tapPublisher
            .sink { _ in action() }
            .store(in: &cancellables)
    }

    public convenience init(
        title: String?,
        style: UIBarButtonItem.Style,
        cancellables: inout Set<AnyCancellable>,
        action: @escaping () -> Void
    ) {
        self.init(title: title, style: style, target: nil, action: nil)
        tapPublisher
            .sink { _ in action() }
            .store(in: &cancellables)
    }

    public convenience init(
        barButtonSystemItem systemItem: UIBarButtonItem.SystemItem,
        cancellables: inout Set<AnyCancellable>,
        action: @escaping () -> Void
    ) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
        tapPublisher
            .sink { _ in action() }
            .store(in: &cancellables)
    }
}
#endif
