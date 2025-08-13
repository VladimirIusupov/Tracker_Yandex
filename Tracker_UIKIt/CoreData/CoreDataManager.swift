import CoreData

enum CoreDataError: Error {
    case invalidRequest
}

final class CoreDataManager {

    // MARK: - Static Properties
    static let shared = CoreDataManager()

    // MARK: - Public Properties
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Private Properties
    private let persistentContainer: NSPersistentContainer

    // MARK: - Init
    private init() {
        DaysValueTransformer.register()
        UIColorValueTransformer.register()

        persistentContainer = NSPersistentContainer(name: "Tracker")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
    }

    // MARK: - Public Methods
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("[CoreDataManager.saveContext]: Контекст успешно сохранён.")
            } catch {
                context.rollback()
                print("[CoreDataManager.saveContext]: Ошибка при сохранении контекста — \(error.localizedDescription)")
            }
        }
    }

    func fetchedResultsController<T: NSManagedObject>(
        fetchRequest: NSFetchRequest<T>,
        sortDescriptors: [NSSortDescriptor],
        sectionNameKeyPath: String? = nil,
        cacheName: String? = nil,
        prefetchRelationships: [String] = []
    ) -> NSFetchedResultsController<T> {
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.relationshipKeyPathsForPrefetching = prefetchRelationships

        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: cacheName
        )
    }

    func fetchFirstObject<T: NSManagedObject>(
        ofType type: T.Type,
        predicate: NSPredicate? = nil
    ) throws -> T? {
        let request = T.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1

        guard let typedRequest = request as? NSFetchRequest<T> else {
            throw CoreDataError.invalidRequest
        }

        return try context.fetch(typedRequest).first
    }
}
