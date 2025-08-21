import Foundation

final class UserLoginStorage {

    // MARK: - Public Properties
    var isUserLogged: Bool {
        get {
            return UserDefaults.standard.bool(forKey: loginKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: loginKey)
        }
    }

    // MARK: - Private Properties
    private let loginKey: String = "loginKey"
}
