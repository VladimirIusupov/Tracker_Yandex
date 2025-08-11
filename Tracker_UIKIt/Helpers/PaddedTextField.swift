import UIKit

final class PaddedTextField: UITextField {

    // MARK: - Private Properties
    private let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    // MARK: - Overrides Methods
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
