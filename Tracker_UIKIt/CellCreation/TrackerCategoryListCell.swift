import UIKit

final class TrackerCategoryListCell: UITableViewCell {

    // MARK: - Static properties
    static let reuseIdentifier = "categoryCell"

    // MARK: - Private Properties
    private lazy var titlelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.textAlignment = .left
        return label
    }()

    private lazy var tickImageView: UIImageView = {
        let image = UIImage(named: "tick")
        return UIImageView(image: image)
    }()

    // MARK: - Init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupSubviews()
        setupConstraints()
    }

    // MARK: - Public Methods
    func configure(with viewModel: TrackerCategoryViewModel) {
        titlelabel.text = viewModel.trackerCategory.name
        tickImageView.isHidden = !viewModel.isSelected
    }

    func roundCornersIfNeeded(isLast: Bool) {
        contentView.layer.cornerRadius = isLast ? 16 : 0
        contentView.layer.masksToBounds = true

        if isLast {
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        contentView.backgroundColor = .ypBackground
        tickImageView.isHidden = true
        contentView.addSubview(titlelabel)
        contentView.addSubview(tickImageView)
    }

    private func setupConstraints() {
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        tickImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titlelabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titlelabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titlelabel.trailingAnchor.constraint(equalTo: tickImageView.leadingAnchor),

            tickImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tickImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
}

