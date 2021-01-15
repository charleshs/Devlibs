import UIKit
import Devlibs

private let cellId = String(describing: MainTableViewCell.self)

final class MainViewController: BaseTableViewController {
    private var sections: [Section] = []

    private let appRouter: AppRouter

    required init(appRouter: AppRouter) {
        self.appRouter = appRouter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: cellId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension MainViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowAt(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MainTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = row.title
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowAt(indexPath).selectHandler(self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func rowAt(_ indexPath: IndexPath) -> Row {
        return sections[indexPath.section].rows[indexPath.item]
    }
}

private extension MainViewController {
    struct Section {
        let title: String?
        var rows: [Row]
    }

    struct Row {
        let title: String?
        let selectHandler: (UIViewController) -> Void
    }
}
