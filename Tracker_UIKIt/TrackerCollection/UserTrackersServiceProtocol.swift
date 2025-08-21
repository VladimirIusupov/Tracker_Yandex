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
    func setFilteredCategories(_ categories: [TrackerCategory])
    func getAllTrackersCount() -> Int
}
