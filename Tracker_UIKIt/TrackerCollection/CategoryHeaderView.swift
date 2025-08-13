import UIKit

final class CategoryHeaderView: UICollectionReusableView {

    // MARK: - Static Properties
    static let identifier = "CategoryHeaderView"
    
    // MARK: - Private Properties
    private let titleLabel = UILabel()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func setTitle(_ title: String) {
        self.titleLabel.text = title
    }

    // MARK: - Private Methods
    func setupTitleLabel() {
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .ypBlack

        addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -12),
        ])
    }
}
