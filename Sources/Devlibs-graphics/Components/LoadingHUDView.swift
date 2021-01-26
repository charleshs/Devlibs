#if os(iOS) || os(tvOS)
import UIKit
import Devlibs_core

open class LoadingHUDView: UIView, SingleViewWrappingContainer {
    /// The container background for the HUD view.
    public var hudColor: UIColor? {
        get {
            hudContainerView.backgroundColor
        }
        set {
            hudContainerView.backgroundColor = newValue
        }
    }

    /// The corner radius of the HUD view.
    public var hudCornerRadius: CGFloat {
        get {
            hudContainerView.layer.cornerRadius
        }
        set {
            hudContainerView.layer.cornerRadius = newValue
        }
    }

    /// The insets of the loading indicator to the container.
    public var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20) {
        didSet {
            adjust(insets: edgeInsets)
            invalidateIntrinsicContentSize()
        }
    }

    /// The text of the label.
    public var title: String? {
        get {
            textLabel.text
        }
        set(title) {
            textLabel.text = title
        }
    }

    /// The font of the label.
    public var font: UIFont {
        get {
            textLabel.font
        }
        set(font) {
            textLabel.font = font
        }
    }

    var wrappedViewTopConstraint: NSLayoutConstraint!
    var wrappedViewLeftConstraint: NSLayoutConstraint!
    var wrappedViewRightConstraint: NSLayoutConstraint!
    var wrappedViewBottomConstraint: NSLayoutConstraint!

    private let hudContainerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 0.8
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 12
    }

    private let loadingIndicatorView = UIActivityIndicatorView().then {
        $0.style = .whiteLarge
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.hidesWhenStopped = true
        $0.startAnimating()
    }

    private let textLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.textColor = Theme.dark.foregroundColor
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }

    public convenience init(theme: Theme, title: String? = nil) {
        self.init(frame: .zero)

        hudContainerView.backgroundColor = theme.backgroundColor
        loadingIndicatorView.color = theme.foregroundColor
        textLabel.textColor = theme.foregroundColor
        textLabel.text = title
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    /// Displays the loading HUD view.
    open func startAnimating() {
        isHidden = false
    }

    /// Hides the loading HUD view.
    open func stopAnimating() {
        isHidden = true
    }

    private func sharedInit() {
        backgroundColor = .whiteClear

        addSubview(hudContainerView)
        hudContainerView.anchorEdges(to: self)

        let stackView = UIStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 16)
        stackView.addArrangedSubviews([loadingIndicatorView, textLabel])
        hudContainerView.addSubview(stackView)

        // SingleViewWrappingContainer
        paste(child: stackView, toParent: hudContainerView)
        adjust(insets: edgeInsets)
    }
}

extension LoadingHUDView {
    public enum Theme {
        case light
        case dark

        var backgroundColor: UIColor {
            switch self {
            case .light:
                return .lightGray
            case .dark:
                return .darkGray
            }
        }

        var foregroundColor: UIColor {
            switch self {
            case .light:
                return .darkGray
            case .dark:
                return .white
            }
        }
    }
}
#endif
