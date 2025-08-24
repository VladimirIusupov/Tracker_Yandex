import UIKit

protocol FiltersProtocol: AnyObject {
    func didSelectFilter(_ filter: Filter)
}

enum Filter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var name: String {
        switch self {
        case .all:
            return L10n.Filters.all
        case .today:
            return L10n.Filters.today
        case .completed:
            return L10n.Filters.completed
        case .uncompleted:
            return L10n.Filters.uncompleted
        }
    }
}
final class FiltersViewController: UIViewController {

    // MARK: - Public Properties
    weak var delegate: FiltersProtocol?
    var currentFilter:Filter?

    // MARK: - Private Properties
    private let filters = Filter.allCases
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false

        tableView.tableHeaderView = UIView()
        tableView.separatorColor = .ypGray
        return tableView
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .ypBlack
        navigationItem.title = L10n.Trackers.filters

        setupSubviews()
        setupConstraints()
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        view.backgroundColor = .ypWhite
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

    private func setupSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        if indexPath.row == filters.count-1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

// MARK: - UITableView
extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        setupSeparator(for: cell, at: indexPath)
        cell.accessoryView = UIImageView(image: UIImage(named: "tick"))
        cell.textLabel?.text = filters[indexPath.row].name
        cell.accessoryView?.isHidden = filters[indexPath.row] != currentFilter
        cell.backgroundColor = .ypBackground
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryView?.isHidden = false
        delegate?.didSelectFilter(filters[indexPath.row])
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryView?.isHidden = true
    }
}

