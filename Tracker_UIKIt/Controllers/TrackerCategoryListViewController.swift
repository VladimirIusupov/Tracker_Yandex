import UIKit

final class TrackerCategoryListViewController: UIViewController {

    // MARK: - Public Properties
    var viewModel: TrackerCategoryListViewModel?

    // MARK: - Private Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(TrackerCategoryListCell.self, forCellReuseIdentifier: TrackerCategoryListCell.reuseIdentifier)
        tableView.tableHeaderView = UIView()
        return tableView
    }()

    private lazy var emptyView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var errorView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var starImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "star"))
        return imageView
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно \nобъеденить по смыслу"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        return button
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .ypBlack
        navigationItem.title = "Категория"

        bindViewModel()
        setupSubviews()
        setupConstraints()
    }

    // MARK: - Private Methods
    private func bindViewModel() {
        viewModel?.navigateToCreateCategory = { [weak self] in
            DispatchQueue.main.async {
                let viewController = CategoryCreationViewController()
                viewController.delegate = self?.viewModel
                let navController = UINavigationController(rootViewController: viewController)
                navController.modalPresentationStyle = .formSheet
                self?.present(navController, animated: true)
            }
        }

        viewModel?.navigateBack = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true)
            }
        }

        viewModel?.categoryStateBinding = { [weak self] isHidden in
            DispatchQueue.main.async {
                self?.emptyView.isHidden = isHidden
            }
        }

        viewModel?.categoryBinding = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel?.updateCategoryState()
    }

    private func setupSubviews() {
        view.backgroundColor = .ypWhite
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(button)
        emptyView.addSubview(errorView)
        errorView.addSubview(starImageView)
        errorView.addSubview(errorLabel)
    }

    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            errorView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor),

            starImageView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            starImageView.topAnchor.constraint(equalTo: errorView.topAnchor),
            starImageView.heightAnchor.constraint(equalToConstant: 80),
            starImageView.widthAnchor.constraint(equalToConstant: 80),

            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 8),
            errorLabel.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16),

            button.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        if indexPath.row == viewModel.categories.count-1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }

    @objc
    private func onButtonTapped() {
        viewModel?.onButtonTapped()
    }
}

// MARK: - UITableView
extension TrackerCategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.categories.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackerCategoryListCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCategoryListCell,
              let category = viewModel?.categories[indexPath.row] else {
            return UITableViewCell()
        }

        let isLast = indexPath.row == (viewModel?.categories.count ?? 0) - 1
        cell.roundCornersIfNeeded(isLast: isLast)
        setupSeparator(for: cell, at: indexPath)
        cell.configure(with: category)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.categorySelected(at: indexPath.row)
    }
}
