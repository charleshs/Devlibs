import UIKit
import Devlibs

class BaseTableViewController: UITableViewController {
    class var backgroundColor: UIColor {
        return UIColor.white
    }

    #if DEBUG
    deinit {
        Logger.log("deinit: \(self.description)", .init(.debug))
    }
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Self.backgroundColor
        tableView.backgroundColor = Self.backgroundColor
        setupBackBarButtonItem()
    }
    
    private func setupBackBarButtonItem() {
        let backImage = UIImage(systemName: "chevron.backward")?.withRenderingMode(.alwaysTemplate)
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .darkGray
    }
}
