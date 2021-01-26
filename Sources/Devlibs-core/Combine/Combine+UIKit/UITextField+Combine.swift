#if canImport(Combine) && (os(iOS) || os(tvOS))
import Combine
import UIKit

@available(iOS 13.0, tvOS 13.0, *)
extension UITextField {
    /// A publisher emitting text changes only when this text field is being edited.
    public var editingTextPublisher: AnyPublisher<String?, Never> {
        Publishers.ControlProperty<UITextField, String?>(control: self, events: .editingChanged, keyPath: \.text)
            .eraseToAnyPublisher()
    }

    /// A publisher emitting any text changes to this text field.
    public var textPublisher: AnyPublisher<String?, Never> {
        Publishers.ControlProperty<UITextField, String?>(control: self, events: .valueEvents, keyPath: \.text)
            .eraseToAnyPublisher()
    }

    /// A publisher emitting any attributed text changes to this text field.
    public var attributedTextPublisher: AnyPublisher<NSAttributedString?, Never> {
        Publishers.ControlProperty<UITextField, NSAttributedString?>(control: self, events: .valueEvents, keyPath: \.attributedText)
            .eraseToAnyPublisher()
    }

    /// A publisher that emits whenever the user taps the return button and ends the editing on the text field.
    public var returnPublisher: AnyPublisher<UITextField, Never> {
        controlEventPublisher(for: .editingDidEndOnExit)
            .map { $0 as! UITextField }
            .eraseToAnyPublisher()
    }
}
#endif
