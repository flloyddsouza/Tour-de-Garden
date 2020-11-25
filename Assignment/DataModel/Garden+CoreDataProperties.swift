//
//  Garden+CoreDataProperties.swift
//  Assignment
//
//  Created by user174137 on 9/19/20.
//  Copyright © 2020 Monash University. All rights reserved.
//
//

import Foundation
import CoreData


extension Garden {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Garden> {
        return NSFetchRequest<Garden>(entityName: "Garden")
    }

    @NSManaged public var name: String?
    @NSManaged public var exhibits: NSSet?

}

// MARK: Generated accessors for exhibits
extension Garden {

    @objc(addExhibitsObject:)
    @NSManaged public func addToExhibits(_ value: Exhibit)

    @objc(removeExhibitsObject:)
    @NSManaged public func removeFromExhibits(_ value: Exhibit)

    @objc(addExhibits:)
    @NSManaged public func addToExhibits(_ values: NSSet)

    @objc(removeExhibits:)
    @NSManaged public func removeFromExhibits(_ values: NSSet)

}
