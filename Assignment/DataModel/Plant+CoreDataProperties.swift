//
//  Plant+CoreDataProperties.swift
//  Assignment
//
//  Created by user174137 on 9/19/20.
//  Copyright © 2020 Monash University. All rights reserved.
//
//

import Foundation
import CoreData


extension Plant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plant> {
        return NSFetchRequest<Plant>(entityName: "Plant")
    }

    @NSManaged public var family: String?
    @NSManaged public var name: String?
    @NSManaged public var sciName: String?
    @NSManaged public var url: String?
    @NSManaged public var year: Int16
    @NSManaged public var exhibitss: NSSet?

}

// MARK: Generated accessors for exhibitss
extension Plant {

    @objc(addExhibitssObject:)
    @NSManaged public func addToExhibitss(_ value: Exhibit)

    @objc(removeExhibitssObject:)
    @NSManaged public func removeFromExhibitss(_ value: Exhibit)

    @objc(addExhibitss:)
    @NSManaged public func addToExhibitss(_ values: NSSet)

    @objc(removeExhibitss:)
    @NSManaged public func removeFromExhibitss(_ values: NSSet)

}
