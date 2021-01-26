import UIKit
import Devlibs

final class MainViewController: BaseTableViewController {
    private lazy var sections: [Section] = [
        uiComponentSection
    ]

    private let appRouter: AppRouter

    // MARK: - Initializer
    
    required init(appRouter: AppRouter) {
        self.appRouter = appRouter
        super.init(style: .grouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: - Data

private extension MainViewController {
    struct Section {
        let title: String?
        var rows: [Row]
    }

    struct Row {
        let title: String?
        let onSelected: (MainViewController) -> Void
    }

    var uiComponentSection: Section {
        return Section(
            title: "UI Components",
            rows: [
                Row(title: "Loading HUD View (Light)") { [appRouter] in
                    $0.push(appRouter.componentGallery(LoadingHUDView(theme: .light, title: "Loading"), layoutSize: .natural))
                },
                Row(title: "Loading HUD View (Dark)") { [appRouter] in
                    $0.push(appRouter.componentGallery(LoadingHUDView(theme: .dark, title: "Loading"), layoutSize: .natural))
                },
                Row(title: "Container View") { [appRouter] in
                    let contentView = Label().then {
                        $0.backgroundColor = .yellow
                        $0.text = "Content View"
                        $0.textColor = .darkText
                    }
                    let containerView = ContainerView(
                        contentView: contentView,
                        contentInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
                    ).then {
                        $0.backgroundColor = .green
                    }
                    $0.push(appRouter.componentGallery(containerView, layoutSize: .natural))
                },
            ]
        )
    }
}

// MARK: - UITableView

extension MainViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowAt(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.reuseIdentifier, for: indexPath) as! MainTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = row.title
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return Label().then {
            $0.text = sections[section].title
            $0.font = .preferredFont(forTextStyle: .headline)
            $0.textColor = .darkGray
            $0.textInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowAt(indexPath).onSelected(self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func rowAt(_ indexPath: IndexPath) -> Row {
        return sections[indexPath.section].rows[indexPath.item]
    }
    
    private func push(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}
