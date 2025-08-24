import Foundation

protocol TrackerRecordStoreProtocol {
    var trackerRecords: [TrackerRecord] { get }
    func add(_ trackerRecord: TrackerRecord) throws
    func delete(with trackerId: UUID, on date: Date, using calendar: Calendar)
}

enum TrackerRecordStoreError: Error {
    case decodingError
    case trackerNotFound
}

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    
    static let shared = TrackerRecordStore()
    
    // MARK: - Private Properties
    private let coreDataManager = CoreDataManager.shared
    private(set) var trackerRecords: [TrackerRecord] = []
    
    // MARK: - Init
    private init() {
        fetchTrackerRecords()
    }
    
    // MARK: - Public Methods
    func add(_ trackerRecord: TrackerRecord) throws {
        let predicate = NSPredicate(format: "id == %@", trackerRecord.trackerId as CVarArg)
        guard let trackerCoreData = try? coreDataManager.fetchFirstObject(ofType: TrackerCoreData.self, predicate: predicate) else {
            print("[TrackerRecordStore.add]: Не удалось удалить трекер")
            throw TrackerRecordStoreError.trackerNotFound
        }
        
        let trackerRecordCoreData = TrackerRecordCoreData(context: coreDataManager.context)
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.tracker = trackerCoreData
        
        coreDataManager.saveContext()
        fetchTrackerRecords()
    }
    
    func delete(with trackerId: UUID, on date: Date, using calendar: Calendar) {
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", trackerId as CVarArg),
            NSPredicate(format: "date >= %@ AND date < %@", dayStart as NSDate, dayEnd as NSDate)
        ])
        
        do {
            if let record = try coreDataManager.fetchFirstObject(
                ofType: TrackerRecordCoreData.self,
                predicate: predicate
            ) {
                coreDataManager.context.delete(record)
                coreDataManager.saveContext()
            }
            fetchTrackerRecords()
        } catch {
            print("[TrackerRecordStore.delete]: Не удалось удалить запись — \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    private func fetchTrackerRecords() {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
        
        do {
            let coreDataRecords = try coreDataManager.context.fetch(fetchRequest)
            self.trackerRecords = coreDataRecords.compactMap { try? trackerRecord(from: $0) }
        } catch {
            print("[TrackerRecordStore.fetchTrackerRecords]: Не удалось выполнить fetch — \(error.localizedDescription)")
            self.trackerRecords = []
        }
    }
    
    private func trackerRecord(from coreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let date = coreData.date,
            let tracker = coreData.tracker,
            let trackerID = tracker.id
        else {
            print("[TrackerRecordStore.trackerRecord]: Ошибка декодирования TrackerRecordCoreData")
            throw TrackerRecordStoreError.decodingError
        }
        
        return TrackerRecord(trackerId: trackerID, date: date)
    }
}
