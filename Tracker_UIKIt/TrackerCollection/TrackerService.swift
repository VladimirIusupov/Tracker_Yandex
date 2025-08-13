import Foundation

final class TrackerService: UserTrackersServiceProtocol {
    // MARK: - Public Properties
    weak var delegate: UserTrackersServiceDelegate?

    private(set) var categories: [TrackerCategory] = []
    private(set) var completedTrackers: [TrackerRecord] = []

    // MARK: - Private Properties
    private let trackerStore: TrackerStorable
    private let trackerCategoryStore: TrackerCategoryStorable
    private let trackerRecordStore: TrackerRecordStorable

    // MARK: - Init
    init(
        trackerStore: TrackerStore = TrackerStore(),
        trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        trackerRecordStore: TrackerRecordStore = TrackerRecordStore()
    ) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore

        addCategory(TrackerCategory(name: "Домашний уют", trackers: []))
        self.categories = trackerCategoryStore.categories
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
        return trackerCategoryStore.categories
    }

    func addTracker(tracker: Tracker, to category: TrackerCategory) {
        do {
            try trackerStore.add(tracker, to: category)
            syncCategories()
            notifyUpdate()
        } catch {
            print("[TrackerService.addTracker]: Ошибка при добавлении трекера — \(error)")
        }
    }

    func addTrackerRecord(_ record: TrackerRecord) {
        do {
            try trackerRecordStore.add(record)
            syncCompletedTrackers()
        } catch {
            print("[TrackerService.addTrackerRecord]: Ошибка при добавлении записи — \(error)")
        }
    }

    func removeTrackerRecord(_ record: TrackerRecord, forDate date: Date, using calendar: Calendar) {
        trackerRecordStore.delete(with: record.trackerId, on: date, using: calendar)
        syncCompletedTrackers()
    }

    func setFilteredCategories(_ categories: [TrackerCategory]) {
        self.categories = categories
    }

    func getAllTrackersCount() -> Int {
        return categories.flatMap { $0.trackers }.count
    }

    // MARK: - Private Methods
    private func syncCategories() {
        categories = trackerCategoryStore.categories
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
