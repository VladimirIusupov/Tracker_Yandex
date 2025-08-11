import Foundation

protocol UserTrackersServiceProtocol {
    var delegate: UserTrackersServiceDelegate? { get set }
    var categories: [TrackerCategory] { get }
    var completedTrackers: [TrackerRecord] { get }
    func addCategory(_ category: TrackerCategory)
    func getAllCategories() -> [TrackerCategory]
    func addTracker(tracker: Tracker, to category: TrackerCategory)
    func addTrackerRecord(_ record: TrackerRecord)
    func removeTrackerRecord(_ record: TrackerRecord, forDate date: Date, using calendar: Calendar)
    func updateDisplayedCategories(categories: [TrackerCategory])
    func getAllTrackersCount() -> Int
}

final class UserTrackersService: UserTrackersServiceProtocol {
    
    // MARK: - Public Properties
    weak var delegate: UserTrackersServiceDelegate?
    
    lazy var categories: [TrackerCategory] = categoriesSource
    lazy var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Private Properties

    private lazy var categoriesSource: [TrackerCategory] = []
    
    // MARK: - Public Methods
    func addCategory(_ category: TrackerCategory) {
        if categoriesSource.contains(where: { $0.name == category.name }) { return }
        categoriesSource.append(category)
    }

    func getAllCategories() -> [TrackerCategory] {
        return categoriesSource
    }

    func addTracker(tracker: Tracker, to category: TrackerCategory) {
        addCategory(category)
        if let categoryIndex = categoriesSource.firstIndex(where: { $0.name == category.name }) {
            let category = categoriesSource[categoryIndex]
            let updatedCategory = TrackerCategory(name: category.name, trackers: category.trackers + [tracker])
            
            categoriesSource[categoryIndex] = updatedCategory
            categories = categoriesSource
            delegate?.reloadData()
        }
    }

    func addTrackerRecord(_ record: TrackerRecord) {
        completedTrackers.append(record)
    }

    func removeTrackerRecord(_ record: TrackerRecord, forDate date: Date, using calendar: Calendar) {
        completedTrackers.removeAll { $0.trackerId == record.trackerId && calendar.isDate($0.date, inSameDayAs: date) }
    }

    func updateDisplayedCategories(categories: [TrackerCategory]) {
        self.categories = categories
    }

    func getAllTrackersCount() -> Int {
        return categories.flatMap { $0.trackers }.count
    }
}

