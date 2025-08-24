import Foundation

extension Notification.Name {
    static let trackersDataUpdated = Notification.Name("trackersDataUpdated")
}

final class TrackerService: UserTrackersServiceProtocol {
    
    // MARK: - Public Properties
    weak var delegate: UserTrackersServiceDelegate?

    private(set) var categories: [TrackerCategory] = []
    private(set) var completedTrackers: [TrackerRecord] = []

    // MARK: - Private Properties
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    private let userDefaultsStorage = UserDefaultsStorage()

    // MARK: - Init
    init(
        trackerStore: TrackerStore = TrackerStore(),
        trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore.shared,
        trackerRecordStore: TrackerRecordStore = TrackerRecordStore.shared
    ) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore

        self.categories = trackerCategoryStore.categories
        pin()
        self.completedTrackers = trackerRecordStore.trackerRecords
    }

    // MARK: - Public Methods
    func addCategory(_ category: TrackerCategory) {
        do {
            try trackerCategoryStore.add(category)
            syncCategories()
        }
        catch {
            print("[TrackerService.addCategory]: Не удалось добавить категорию")
        }
    }

    func getAllCategories() -> [TrackerCategory] {
        syncCategories()
        pin()
        return categories
    }

    func addTracker(tracker: Tracker, to category: TrackerCategory) {
        do {
            try trackerStore.add(tracker, to: category)
            syncCategories()
            pin()
            notifyUpdate()
        } catch {
            print("[TrackerService.addTracker]: Ошибка при добавлении трекера — \(error)")
        }
    }

    func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.delete(tracker)
            syncDeletion(tracker: tracker)
            pin()
            notifyUpdate()
        } catch {
            print("[TrackerService.deleteTracker]: Ошибка при удалении трекера — \(error)")
        }
    }

    func updateTracker(_ tracker: Tracker,with trackerCategory: TrackerCategory) {
        do {
            try trackerStore.update(tracker, with: trackerCategory)
            syncUpdate(tracker: tracker)
            pin()
            notifyUpdate()
        } catch {
            print("[TrackerService.updateTracker]: Ошибка при обновлении трекера — \(error)")
        }
    }

    func addTrackerRecord(_ record: TrackerRecord) {
        do {
            try trackerRecordStore.add(record)
            syncCompletedTrackers()
            NotificationCenter.default.post(name: .trackersDataUpdated, object: nil)
        } catch {
            print("[TrackerService.addTrackerRecord]: Ошибка при добавлении записи — \(error)")
        }
    }

    func removeTrackerRecord(_ record: TrackerRecord, forDate date: Date, using calendar: Calendar) {
        trackerRecordStore.delete(with: record.trackerId, on: date, using: calendar)
        syncCompletedTrackers()
        NotificationCenter.default.post(name: .trackersDataUpdated, object: nil)
    }

    func setFilteredCategories(_ categories: [TrackerCategory]) {
        self.categories = categories
    }

    func getAllTrackersCount() -> Int {
        return categories.flatMap { $0.trackers }.count
    }

    func isPinned(trackerId: UUID) -> Bool {
        return userDefaultsStorage.pinnedTrackers.contains(trackerId)
    }

    func togglePin(trackerId: UUID) {
        if !isPinned(trackerId: trackerId) {
            userDefaultsStorage.pinTracker(trackerId)
        } else {
            userDefaultsStorage.unpinTracker(trackerId)
        }
        pin()
        notifyUpdate()
    }

    func hasPinned() -> Bool {
        return !userDefaultsStorage.pinnedTrackers.isEmpty
    }

    func getCategory(of tracker: Tracker) -> TrackerCategory? {
        let category = trackerCategoryStore.categories.first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) })
        return category
    }

    // MARK: - Private Methods
    private func syncCategories() {
        categories = trackerCategoryStore.categories
    }

    private func syncUpdate(tracker: Tracker) {
        let updated = categories.map { category in
             TrackerCategory(
                name: category.name,
                trackers: category.trackers.filter{$0.id != tracker.id} + [tracker]
            )
        }
        categories = updated
    }

    private func syncDeletion(tracker: Tracker) {
        let updated = categories.map { category in
             TrackerCategory(
                name: category.name,
                trackers: category.trackers.filter{$0.id != tracker.id}
            )
        }
        categories = updated
    }

    private func pin() {
        let pinnedIDs = userDefaultsStorage.pinnedTrackers
        let allCategories = trackerCategoryStore.categories

        var filtered = allCategories.map { category in
            TrackerCategory(
                name: category.name,
                trackers: category.trackers.filter { !pinnedIDs.contains($0.id) }
            )
        }

        if !pinnedIDs.isEmpty {
            let pinned = allCategories
                .flatMap { $0.trackers }
                .filter { pinnedIDs.contains($0.id) }

            filtered.insert(TrackerCategory(name: L10n.Trackers.pinned, trackers: pinned), at: 0)
        }

        let currentTrackersIDs = categories.flatMap(\.trackers).map(\.id)

        let answer = filtered.map { category in
            TrackerCategory(
                name: category.name,
                trackers: category.trackers.filter { currentTrackersIDs.contains($0.id)}
            )

        }
        categories = answer

    }

    private func syncCompletedTrackers() {
        completedTrackers = trackerRecordStore.trackerRecords
    }

    private func notifyUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.reloadData()
        }
    }
}
