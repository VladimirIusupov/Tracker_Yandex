import UIKit

protocol ScheduleTableViewCellDelegate: AnyObject {
    func switchTableViewCell(_ cellName: String?, didChangeValue isOn: Bool)
}

final class ScheduleTableViewCell: UITableViewCell {
    
    // MARK: - Static Properties
    static let identifier = "ScheduleTableViewCell"
    
    // MARK: - Public Properties
    weak var delegate: ScheduleTableViewCellDelegate?
    
    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.textAlignment = .left
        return label
    }()
    
    private lazy var toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        toggleSwitch.onTintColor = .ypBlue
        return toggleSwitch
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
    func setupCell(withTitle title: String, isOn: Bool) {
        self.titleLabel.text = title
        self.toggleSwitch.isOn = isOn
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        contentView.backgroundColor = .ypBackground
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26.5),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26.5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            toggleSwitch.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            toggleSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            toggleSwitch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc
    private func switchChanged() {
        delegate?.switchTableViewCell(titleLabel.text, didChangeValue: toggleSwitch.isOn)
    }
}
