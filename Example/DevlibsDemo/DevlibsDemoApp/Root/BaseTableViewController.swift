import UIKit

class BaseTableViewController: UITableViewController {
    class var backgroundColor: UIColor {
        return UIColor.white
    }

    #if DEBUG
    deinit { print("$%^deinit \(self.description)") }
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Self.backgroundColor
        tableView.backgroundColor = Self.backgroundColor
    }
}
