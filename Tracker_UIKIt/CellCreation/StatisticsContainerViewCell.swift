import UIKit

final class StatisticsContainerViewCell: UITableViewCell {
    
    // MARK: - Static Properties
    static let reuseIdentifier = "statisticsContainerCell"
    
    // MARK: - Private Properties
    private lazy var gradientBorderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.addSublayer(gradientLayer)
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let gradientLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGradientBorder()
        setupSubviews()
        setupConstraints()
    }
    
    // MARK: - Public Methods
    func configure(with value: Int, to title: String) {
        valueLabel.text = String(value)
        titleLabel.text = title
        
        layoutIfNeeded()
        gradientLayer.frame = gradientBorderView.bounds
        updateMaskPath()
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(gradientBorderView)
        gradientBorderView.addSubview(contentContainerView)
        contentContainerView.addSubview(valueLabel)
        contentContainerView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gradientBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            contentContainerView.topAnchor.constraint(equalTo: gradientBorderView.topAnchor, constant: 1),
            contentContainerView.leadingAnchor.constraint(equalTo: gradientBorderView.leadingAnchor, constant: 1),
            contentContainerView.trailingAnchor.constraint(equalTo: gradientBorderView.trailingAnchor, constant: -1),
            contentContainerView.bottomAnchor.constraint(equalTo: gradientBorderView.bottomAnchor, constant: -1),
            
            valueLabel.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -12),
        ])
    }
    
    private func setupGradientBorder() {
        gradientLayer.colors = [
            UIColor.gradient3.cgColor,
            UIColor.gradient2.cgColor,
            UIColor.gradient1.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        borderMaskLayer.fillColor = nil
        borderMaskLayer.lineWidth = 1
        borderMaskLayer.strokeColor = UIColor.ypWhite.cgColor
        gradientLayer.mask = borderMaskLayer
    }
    
    private func updateMaskPath() {
        let inset = borderMaskLayer.lineWidth / 2
        let roundedRect = gradientBorderView.bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: 16)
        borderMaskLayer.path = path.cgPath
    }
}

