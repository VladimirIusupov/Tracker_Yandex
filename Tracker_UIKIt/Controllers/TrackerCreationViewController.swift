import UIKit

final class TrackerCreationViewController: UIViewController {

    // MARK: - Public Properties
    weak var delegate: CreationDelegate?

    // MARK: - Private Properties
    private let tableViewItems: [String] = ["Категория", "Расписание"]

    private var schedule: Set<Day> = []
    private var category: TrackerCategory? = TrackerCategory(name: "Домашний уют", trackers: [])
    private var emoji:Character? = "😄"
    private var color: UIColor? = .selection16

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        view.addSubview(button)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let color: UIColor = .ypRed
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(color, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = color.cgColor
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()

    private lazy var trackerNameTextField: UITextField = {
        let textField = PaddedTextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addSubview(textField)
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        return textField
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tableHeaderView = UIView()
        return tableView
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationController?.navigationBar.tintColor = .ypBlack
        navigationItem.title = "Новая привычка"
        setupConstraints()
    }

    // MARK: - Private Methods
    private func createButtonAvailabilityCheck() {
        let isInputValid = trackerNameTextField.hasText && category != nil && schedule.isEmpty == false
        createButton.isEnabled = isInputValid
        createButton.backgroundColor = isInputValid ? .ypBlack : .ypGray
    }

    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),

            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),

            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)

        ])
    }
    
    private func getScheduleSubtitle() -> String {
        if schedule.count == 7 {
            return "Каждый день"
        }
        let shortNames = schedule
            .sorted {
                guard let firstIndex = Day.allCases.firstIndex(of: $0),
                      let secondIndex = Day.allCases.firstIndex(of: $1) else { return false }
                return firstIndex < secondIndex
            }
            .compactMap { $0.shortName }
        return shortNames.joined(separator: ", ")
    }

    private func setupSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        if indexPath.row == tableViewItems.count-1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }

    @objc
    private func cancelTapped() {
        self.dismiss(animated: true)
    }

    @objc
    private func createTapped() {
        guard
            let category,
            let emoji,
            !schedule.isEmpty,
            let color,
            let name = trackerNameTextField.text,
            !name.isEmpty
        else {
            self.dismiss(animated: true)
            return
        }

        delegate?.didCreateTracker(name: name, category: category, emoji: emoji, color: color, schedule: schedule)
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }

    @objc
    private func textFieldDidChange() {
        createButtonAvailabilityCheck()
    }

    @objc
    private func hideKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - UITableView
extension TrackerCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        setupSeparator(for: cell, at: indexPath)

        cell.textLabel?.text = tableViewItems[indexPath.row]
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = category?.name ?? ""
        } else {
            cell.detailTextLabel?.text = getScheduleSubtitle()
        }

        cell.detailTextLabel?.textColor = .ypGray
        cell.textLabel?.textColor = .ypBlack
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)

        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .ypBackground
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let viewController = ScheduleViewController()
            viewController.delegate = self
            viewController.selectedDays = schedule
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true)
        } else if indexPath.row == 0 {
            //TODO: Реализовать переход на экран выбора категорий
        }
    }
}

// MARK: - ScheduleViewControllerDelegate
extension TrackerCreationViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: Set<Day>) {
        schedule = days
        createButtonAvailabilityCheck()
        tableView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension TrackerCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

