import Foundation

extension Int {
    func days() -> String {
        if self > 10 && self < 20 {
            return "\(self) дней"
        }
        let lastDigit = String(self).last
        switch lastDigit {
        case "1":
            return "\(self) день"
        case "2","3","4":
            return "\(self) дня"
        case "5","6","7","8","9","0":
            return "\(self) дней"
        default:
            return "\(self) дней"
        }
    }
}

