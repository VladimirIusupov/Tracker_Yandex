//
//  TrackerRecordCoreData+CoreDataProperties.swift
//  Tracker_UIKIt
//
//  Created by Vladimir Iusupov on 12.08.2025.
//
//

import Foundation
import CoreData


extension TrackerRecordCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var tracker: TrackerCoreData?

}

extension TrackerRecordCoreData : Identifiable {

}
