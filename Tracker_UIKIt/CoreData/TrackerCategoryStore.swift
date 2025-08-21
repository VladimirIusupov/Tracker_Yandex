import UIKit

protocol TrackerCategoryStoreProtocol {
    var categories: [TrackerCategory] { get }
    func add(_ category: TrackerCategory) throws
    func fetchCategory(by name: String) throws -> TrackerCategory?
}

enum TrackerCategoryStoreError: Error {
    case decodingError
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoreProtocol {

    // MARK: - Static Properties
    static let shared = TrackerCategoryStore()

    // MARK: - Public Properties
    var categories: [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { try? category(from: $0) }
    }

    // MARK: - Private Properties
    private let coreDataManager = CoreDataManager.shared
    private lazy var fetchedResultsController = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        return coreDataManager.fetchedResultsController(
            fetchRequest: fetchRequest,
            sortDescriptors: [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)],
            prefetchRelationships: ["trackers"]
        )
    }()

    // MARK: - Init
    private override init() {
        super.init()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("[TrackerCategoryStore.init]: Не удалось выполнить fetch — \(error.localizedDescription)")
        }
    }

    // MARK: - Public Methods
    func add(_ category: TrackerCategory) throws {
        if try fetchCategory(by: category.name) != nil {
            print("[TrackerCategoryStore.add]: Категория \"\(category.name)\" уже существует")
            return
        }

        let trackerCategoryCoreData = TrackerCategoryCoreData(context: coreDataManager.context)
        trackerCategoryCoreData.name = category.name

        coreDataManager.saveContext()
        try? fetchedResultsController.performFetch()
    }

    func fetchCategory(by name: String) throws -> TrackerCategory? {
        let predicate = NSPredicate(format: "name == %@", name)
        guard let coreDataObject = try CoreDataManager.shared.fetchFirstObject(
            ofType: TrackerCategoryCoreData.self,
            predicate: predicate
        ) else {
            return nil
        }

        let fetchedCategory = try category(from: coreDataObject)
        return fetchedCategory
    }

    // MARK: - Private Methods
    private func category(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = trackerCategoryCoreData.name else {
            print("[TrackerCategoryStore.category]: name == nil")
            throw TrackerCategoryStoreError.decodingError
        }

        let trackerCoreDataSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> ?? []
        let trackers = try trackerCoreDataSet.map { trackerCoreData in
            guard
                let id = trackerCoreData.id,
                let name = trackerCoreData.name,
                let emojiString = trackerCoreData.emoji,
                let color = trackerCoreData.color as? UIColor,
                let emoji = emojiString.first
            else {
                print("[TrackerCategoryStore.category]: Не удалось декодировать Tracker")
                throw TrackerCategoryStoreError.decodingError
            }

            guard let scheduleSet = trackerCoreData.schedule as? Set<Day> else {
                print("[TrackerCategoryStore.category]: schedule не является Set<Day> — \(String(describing: trackerCoreData.schedule))")
                throw TrackerCategoryStoreError.decodingError
            }

            return Tracker(
                id: id,
                name: name,
                color: color,
                emoji: emoji,
                schedule: scheduleSet
            )
        }

        return TrackerCategory(name: name, trackers: trackers)
    }
}
