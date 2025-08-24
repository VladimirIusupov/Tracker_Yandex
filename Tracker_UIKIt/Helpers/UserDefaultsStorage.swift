import Foundation

final class UserDefaultsStorage {

    // MARK: - Public Properties
    var isUserLogged: Bool {
        get {
            return UserDefaults.standard.bool(forKey: loginKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: loginKey)
        }
    }

    var pinnedTrackers: [UUID] {
        get {
            guard let data = UserDefaults.standard.data(forKey: pinnedTrackersKey),
                  let uuids = try? JSONDecoder().decode([UUID].self, from: data) else {
                return []
            }
            return uuids
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: pinnedTrackersKey)
        }
    }

    // MARK: - Private Properties
    private let loginKey: String = "loginKey"
    private let pinnedTrackersKey: String = "pinnedTrackersKey"

    // MARK: - Private Methods
    func pinTracker(_ id: UUID) {
        var current = pinnedTrackers
        guard !current.contains(id) else { return }
        current.append(id)
        pinnedTrackers = current
    }
    
    func unpinTracker(_ id: UUID) {
        var current = pinnedTrackers
        current.removeAll { $0 == id }
        pinnedTrackers = current
    }
}

