//
//  Exhibit+CoreDataProperties.swift
//  Assignment
//
//  Created by user174137 on 9/19/20.
//  Copyright © 2020 Monash University. All rights reserved.
//
//

import Foundation
import CoreData


extension Exhibit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exhibit> {
        return NSFetchRequest<Exhibit>(entityName: "Exhibit")
    }

    @NSManaged public var desc: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var name: String?
    @NSManaged public var url: String?
    @NSManaged public var gardens: Garden?
    @NSManaged public var plants: NSSet?

}

// MARK: Generated accessors for plants
extension Exhibit {

    @objc(addPlantsObject:)
    @NSManaged public func addToPlants(_ value: Plant)

    @objc(removePlantsObject:)
    @NSManaged public func removeFromPlants(_ value: Plant)

    @objc(addPlants:)
    @NSManaged public func addToPlants(_ values: NSSet)

    @objc(removePlants:)
    @NSManaged public func removeFromPlants(_ values: NSSet)

}
