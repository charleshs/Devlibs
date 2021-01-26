#if os(iOS) || os(tvOS)
import UIKit

/// A `UIView` wrapper for creating a view with nib.
open class NibView: UIView {
    /// An `IBOutlet` which must be wired up to the root view of xib.
    @IBOutlet
    public private(set) var contentView: UIView! {
        didSet {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(contentView)
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: topAnchor),
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        }
    }

    private var nibName: String {
        return String(describing: type(of: self))
    }

    private var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    private var nib: UINib {
        return UINib(nibName: nibName, bundle: bundle)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = viewFromNib()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView = viewFromNib()
    }

    private func viewFromNib() -> UIView {
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            var errorMsg = "The nib \(nib) expected its file owner to be \(type(of: self)), and "
            errorMsg += "the `contentView` outlet be connected to the root view of xib."
            fatalError(errorMsg)
        }
        return view
    }
}
#endif
