import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {

    // MARK: - Static Properties
    static let identifier = "ColorCollectionViewCell"

    // MARK: - Private Properties
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func setupColor(_ color: UIColor) {
        colorView.backgroundColor = color
    }

    func select() {
        borderView.backgroundColor = colorView.backgroundColor?.withAlphaComponent(0.3)
    }

    func deselect() {
        borderView.backgroundColor = .clear
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(borderView)
        contentView.addSubview(whiteView)
        contentView.addSubview(colorView)
    }

    private func setupConstraints() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        whiteView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            whiteView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            whiteView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            whiteView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3),
            whiteView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),

            borderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
