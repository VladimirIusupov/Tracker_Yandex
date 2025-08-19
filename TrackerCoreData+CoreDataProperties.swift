//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker_UIKIt
//
//  Created by Vladimir Iusupov on 12.08.2025.
//
//

import Foundation
import CoreData


extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var color: NSObject?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var schedule: NSObject?
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var records: TrackerRecordCoreData?

}

extension TrackerCoreData : Identifiable {

}
