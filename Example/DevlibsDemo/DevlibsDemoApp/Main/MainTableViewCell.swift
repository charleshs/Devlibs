import UIKit

final class MainTableViewCell: BaseTableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textLabel?.numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
