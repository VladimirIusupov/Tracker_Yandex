import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    static let identifier = "EmojiCollectionViewCell"

    // MARK: - Private Properties
    private var emoji: Character?

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private lazy var emojiView: UIView = {
        let view = UIView()
        self.contentView.addSubview(view)
        view.layer.cornerRadius = 16
        view.backgroundColor = .clear
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
    func setupEmoji(_ emoji: Character) {
        self.emoji = emoji
        emojiLabel.text = String(emoji)
    }

    func select() {
        emojiView.backgroundColor = .ypLightGray
    }

    func deselect() {
        emojiView.backgroundColor = .clear
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(emojiView)
        emojiView.addSubview(emojiLabel)
    }

    private func setupConstraints() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 52),
            contentView.widthAnchor.constraint(equalToConstant: 52),
            emojiView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiView.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
