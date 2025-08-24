import UIKit

final class OnboardingStepViewController: UIViewController {

    // MARK: - Private Properties
    private let userDefaultsStorage = UserDefaultsStorage()

    private var background = UIImageView()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypAlwaysBlack
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Onboarding.button, for: .normal)
        button.setTitleColor(.ypAlwaysWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypAlwaysBlack
        button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        return button
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()

    }

    // MARK: - Public Methods
    func setup(with backgroundImage: UIImage, title: String) {
        self.background.image = backgroundImage
        self.titleLabel.text = title
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        view.addSubview(background)
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
    }

    private func setupConstraints() {
        background.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc
    private func onButtonTapped() {
        userDefaultsStorage.isUserLogged.toggle()
        let tabBarController = TabBarController()

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = tabBarController

            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: nil,
                completion: nil)
        }
    }
}
