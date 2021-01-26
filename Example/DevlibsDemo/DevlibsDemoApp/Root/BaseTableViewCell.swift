import UIKit

class BaseTableViewCell: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
