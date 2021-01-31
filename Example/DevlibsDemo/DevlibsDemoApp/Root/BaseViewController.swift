import Combine
import UIKit
import Devlibs

class BaseViewController: UIViewController {
    class var backgroundColor: UIColor {
        return UIColor.white
    }

    private var cancellables: Set<AnyCancellable> = []

    #if DEBUG
    deinit {
        Logger.log("deinit: \(self.description)", .init(.debug))
    }
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Self.backgroundColor
        setupNavigationBarButton()
    }

    private func setupNavigationBarButton() {
        if isPresented {
            navigationItem.setRightBarButton(
                UIBarButtonItem(title: "Close", style: .plain, cancellables: &cancellables) { [weak self] in
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                },
                animated: false
            )
        }
    }
}

private extension UIViewController {
    var isPresented: Bool {
        return presentingViewController != nil
    }
}
