import UIKit

final class ComponentViewController: BaseViewController {
    enum LayoutSize {
        case natural
        case filledWidth
        case filledView
    }

    private let component: UIView

    private let layoutSize: LayoutSize

    init(component: UIView, layoutSize: LayoutSize) {
        self.component = component
        self.layoutSize = layoutSize
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        component.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(component)
        setupInitialConstraints()
    }

    private func setupInitialConstraints() {
        let centerXConstraint = component.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let centerYConstraint = component.centerYAnchor.constraint(equalTo: view.centerYAnchor)

        var constraints: [NSLayoutConstraint] = []
        switch layoutSize {
        case .natural:
            constraints.append(contentsOf: [
                component.topAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.topAnchor),
                component.leftAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.leftAnchor),
                view.readableContentGuide.rightAnchor.constraint(greaterThanOrEqualTo: component.rightAnchor),
                view.readableContentGuide.bottomAnchor.constraint(greaterThanOrEqualTo: component.bottomAnchor),
                centerXConstraint,
                centerYConstraint,
            ])
        case .filledWidth:
            constraints.append(contentsOf: [
                component.topAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.topAnchor),
                component.leftAnchor.constraint(equalTo: view.readableContentGuide.leftAnchor),
                view.readableContentGuide.rightAnchor.constraint(equalTo: component.rightAnchor),
                view.readableContentGuide.bottomAnchor.constraint(greaterThanOrEqualTo: component.bottomAnchor),
            ])
        case .filledView:
            constraints.append(contentsOf: [
                component.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
                component.leftAnchor.constraint(equalTo: view.readableContentGuide.leftAnchor),
                view.readableContentGuide.rightAnchor.constraint(equalTo: component.rightAnchor),
                view.readableContentGuide.bottomAnchor.constraint(equalTo: component.bottomAnchor),
            ])
        }

        NSLayoutConstraint.activate(constraints)
    }
}
