import UIKit

protocol TrackerStoreProtocol {
    var trackers: [Tracker] { get }
    func add(_ tracker: Tracker, to category: TrackerCategory) throws
}

enum TrackerStoreError: Error {
    case decodingError
    case categoryNotFound(name: String)
}

final class TrackerStore: NSObject, TrackerStoreProtocol {

    // MARK: - Public Properties
    var trackers: [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { try? tracker(from: $0) }
    }

    // MARK: - Private Properties
    private let coreDataManager = CoreDataManager.shared
    private lazy var fetchedResultsController = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        return coreDataManager.fetchedResultsController(
            fetchRequest: fetchRequest,
            sortDescriptors: [NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)]
        )
    }()

    // MARK: - Init
    override init() {
        super.init()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("[TrackerStore.init]: Ошибка при выполнении fetch — \(error.localizedDescription)")
        }
    }

    // MARK: - Public Methods
    func add(_ tracker: Tracker, to category: TrackerCategory) throws {
        let predicate = NSPredicate(format: "name == %@", category.name)
        guard
            let categoryCoreData = try? coreDataManager.fetchFirstObject(
                ofType: TrackerCategoryCoreData.self,
                predicate: predicate)
        else {
            print("[TrackerStore.add]: Ошибка при поиске категории — \(category.name)")
            throw TrackerStoreError.categoryNotFound(name: category.name)
        }
        let trackerCoreData = TrackerCoreData(context: coreDataManager.context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = String(tracker.emoji)
        trackerCoreData.color = tracker.color
        trackerCoreData.setValue(tracker.schedule, forKey: "schedule")
        trackerCoreData.category = categoryCoreData

        categoryCoreData.addToTrackers(trackerCoreData)

        coreDataManager.saveContext()
    }

    // MARK: - Private Methods
    private func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = trackerCoreData.id,
            let name = trackerCoreData.name,
            let emojiString = trackerCoreData.emoji,
            let emoji = emojiString.first,
            let color = trackerCoreData.color as? UIColor,
            let scheduleSet = trackerCoreData.schedule as? Set<Day>
        else {
            print("""
            [TrackerStore.tracker(from:)]: Ошибка декодирования:
            id: \(String(describing: trackerCoreData.id)),
            name: \(String(describing: trackerCoreData.name)),
            emoji: \(String(describing: trackerCoreData.emoji)),
            color: \(String(describing: trackerCoreData.color)),
            schedule: \(String(describing: trackerCoreData.schedule))
            """)
            throw TrackerStoreError.decodingError
        }

        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: scheduleSet
        )
    }
}
