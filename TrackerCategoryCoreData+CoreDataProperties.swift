//
//  TrackerCategoryCoreData+CoreDataProperties.swift
//  Tracker_UIKIt
//
//  Created by Vladimir Iusupov on 12.08.2025.
//
//

import Foundation
import CoreData


extension TrackerCategoryCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        return NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }

    @NSManaged public var name: String?
    @NSManaged public var trackers: TrackerCoreData?

}

extension TrackerCategoryCoreData : Identifiable {

}
