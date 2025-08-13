import UIKit

final class EventCreationViewController: UIViewController {

    // MARK: - Public Properties
    weak var delegate: CreationDelegate?

    // MARK: - Private Properties
    private var category: TrackerCategory? = TrackerCategory(name: "Домашний уют", trackers: [])
    private var emoji:Character?
    private var color: UIColor?

    private let emojiVariants: [Character] = Constants.emojis
    private let colorVariants: [UIColor] = Constants.colors

    private let scrollView = UIScrollView()
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
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
        button.setTitle("Отменить", for: .normal)
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
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.returnKeyType = .done
        textField.delegate = self
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
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.isScrollEnabled = false

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
        label.text = "Emoji"
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
        label.text = "Цвет"
        return label
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationController?.navigationBar.tintColor = .ypBlack
        navigationItem.title = "Новое нерегулярное событие"
        setupSubviews()
        setupConstraints()
    }

    // MARK: - Private Methods
    private func createButtonAvailabilityCheck() {
        let isInputValid = trackerNameTextField.hasText && category != nil && color != nil && emoji != nil
        createButton.isEnabled = isInputValid
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
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
            tableView.heightAnchor.constraint(equalToConstant: 75),

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

    @objc
    private func cancelTapped() {
        self.dismiss(animated: true)
    }

    @objc
    private func createTapped() {
        guard
            let category,
            let emoji,
            let color,
            let name = trackerNameTextField.text,
            !name.isEmpty
        else {
            self.dismiss(animated: true)
            return
        }

        delegate?.didCreateEvent(name: name, category: category, emoji: emoji, color: color)
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
extension EventCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        cell.textLabel?.text = "Категория"
        cell.detailTextLabel?.text = category?.name ?? ""

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
        // TODO: Реализовать переход к экрану выбора категорий
    }
}

// MARK: - UITextFieldDelegate
extension EventCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EventCreationViewController: UICollectionViewDataSource {
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

extension EventCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
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
