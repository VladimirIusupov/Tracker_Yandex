import UIKit

final class TrackerCreationViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: CreationDelegate?
    
    // MARK: - Private Properties
    private let tableViewItems: [String] = [L10n.Creation.category, L10n.Creation.schedule]

    private var schedule: Set<Day> = []
    private var category: TrackerCategory?
    private var emoji: Character?
    private var color: UIColor?
    
    private let emojiVariants: [Character] = Constants.emojis
    private let colorVariants: [UIColor] = Constants.colors

    private let scrollView = UIScrollView()
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.General.create, for: .normal)
        button.setTitleColor(.ypAlwaysWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let color: UIColor = .ypRed
        button.setTitle(L10n.General.cancel, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = color.cgColor
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = PaddedTextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: L10n.Creation.placeholder,
            attributes: [.foregroundColor: UIColor.ypGray]
        )
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        return textField
    }()
    
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
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        return collectionView
    }()
    
    private lazy var emojiTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypBlack
        label.text = L10n.Creation.emoji
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        return collectionView
    }()
    
    private lazy var colorTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypBlack
        label.text = L10n.Creation.color
        return label
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationController?.navigationBar.tintColor = .ypBlack
        navigationItem.title = L10n.Creation.habitTitle
        setupSubviews()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    private func createButtonAvailabilityCheck() {
        let isInputValid = trackerNameTextField.hasText && category != nil && schedule.isEmpty == false && emoji != nil && color != nil
        createButton.isEnabled = isInputValid
        createButton.setTitleColor(isInputValid ? .ypWhite : .ypAlwaysWhite, for: .normal)
        createButton.backgroundColor = isInputValid ? .ypBlack : .ypGray
    }

    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(createButton)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(trackerNameTextField)
        scrollView.addSubview(tableView)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorCollectionView)
        scrollView.addSubview(emojiTitleLabel)
        scrollView.addSubview(colorTitleLabel)
    }

    private func setupConstraints() {
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        emojiTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: frameGuide.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: frameGuide.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: frameGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: frameGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiTitleLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: frameGuide.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: frameGuide.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: frameGuide.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor,constant: 40),
            cancelButton.leadingAnchor.constraint(equalTo: frameGuide.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: frameGuide.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            createButton.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor, constant: -24),
            
            colorTitleLabel.leadingAnchor.constraint(equalTo: frameGuide.leadingAnchor, constant: 28),
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 40),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: frameGuide.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: frameGuide.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
        ])
    }
    
    private func getScheduleSubtitle() -> String {
        if schedule.count == 7 {
            return L10n.Creation.everyDay
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
            let viewController = TrackerCategoryListViewController()
            viewController.viewModel = TrackerCategoryListViewModel()
            viewController.viewModel?.delegate = self
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true)
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

// MARK: - UICollectionViewDataSource
extension TrackerCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojiVariants.count
        } else {
            return colorVariants.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.setupEmoji(emojiVariants[indexPath.row])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.setupColor(colorVariants[indexPath.row])
            return cell
        }
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        floor(((UIScreen.main.bounds.width - 36) - 52*6)/5)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath)
            emoji = emojiVariants[indexPath.row]
            if let cell = cell as? EmojiCollectionViewCell {
                cell.select()
            }
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            color = colorVariants[indexPath.row]
            if let cell = cell as? ColorCollectionViewCell {
                cell.select()
            }
        }
        createButtonAvailabilityCheck()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath)
            if let cell = cell as? EmojiCollectionViewCell {
                cell.deselect()
            }
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            if let cell = cell as? ColorCollectionViewCell {
                cell.deselect()
            }
        }
    }
}

// MARK: - TrackerCategoryListViewModelDelegate
extension TrackerCreationViewController: TrackerCategoryListViewModelDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        self.category = category
        createButtonAvailabilityCheck()
        tableView.reloadData()
    }
}
