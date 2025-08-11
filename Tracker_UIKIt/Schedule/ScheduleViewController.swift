import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: Set<Day>)
}

final class ScheduleViewController: UIViewController {

    // MARK: - Public Properties
    weak var delegate: ScheduleViewControllerDelegate?
    var selectedDays: Set<Day> = []

    // MARK: - Private Properties
    private let tableViewItems = Day.allCases.compactMap(\.rawValue)

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.identifier)
        tableView.isScrollEnabled = false
        return tableView
    }()
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .ypWhite
        button.backgroundColor = .ypBlack
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        view.addSubview(button)
        return button
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite

        setupConstraints()
        navigationController?.navigationBar.tintColor = .ypBlack
        navigationItem.title = "Расписание"
    }

    // MARK: - Private Properties

    private func setupConstraints() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),

            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func setupSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        if indexPath.row == tableViewItems.count-1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }

    @objc
    private func doneTapped() {
        delegate?.didSelectDays(selectedDays)
        self.dismiss(animated: true)
    }
}

// MARK: - UITableView
extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.identifier, for: indexPath) as? ScheduleTableViewCell
        else {
            return UITableViewCell()
        }
        setupSeparator(for: cell, at: indexPath)
        cell.delegate = self
        cell.selectionStyle = .none
        let isOn = selectedDays.contains(where: { $0.rawValue == tableViewItems[indexPath.row] })
        cell.setupCell(withTitle: tableViewItems[indexPath.row], isOn: isOn)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

}

// MARK: - ScheduleTableViewCellDelegate
extension ScheduleViewController: ScheduleTableViewCellDelegate {
    func switchTableViewCell(_ cellName: String?, didChangeValue isOn: Bool) {
        guard let day = Day(rawValue: cellName ?? "") else { return }
        if isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}

