import UIKit

protocol CategoryCreationDelegate: AnyObject {
    func didCreateCategory(named name: String)
}

final class CategoryCreationViewController: UIViewController {

    // MARK: - Public Properties
    weak var delegate: CategoryCreationDelegate?

    // MARK: - Private Properties
    private lazy var categoryNameTextField: UITextField = {
        let textField = PaddedTextField()
        textField.placeholder = "Введите название категории"
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

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        return button
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .ypBlack
        navigationItem.title = "Новая категория"

        setupSubviews()
        setupConstraints()
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        view.backgroundColor = .ypWhite
        view.addSubview(categoryNameTextField)
        view.addSubview(createButton)
    }

    private func setupConstraints() {
        categoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),

            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func createButtonAvailabilityCheck() {
        let isInputValid = categoryNameTextField.hasText
        createButton.isEnabled = isInputValid
        createButton.backgroundColor = isInputValid ? .ypBlack : .ypGray
    }

    @objc
    private func onButtonTapped() {
        guard let name = categoryNameTextField.text else { return }
        delegate?.didCreateCategory(named: name)
        dismiss(animated: true)
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

// MARK: - UITextFieldDelegate
extension CategoryCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
