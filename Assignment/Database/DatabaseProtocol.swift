//
//  DatabaseProtocol.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/16/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//  Refered to Tutorial Week 4 for Code.
//

import Foundation
enum DatabaseChange {
    case add
    case remove
    case update
}


enum ListenerType {
    case garden
    case exhibits
    case plants
    case all
}


protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onExhibitListChange(change: DatabaseChange, exhibits: [Exhibit])
    func onPlantListChange(change: DatabaseChange, plants: [Plant])
}


protocol DatabaseProtocol: AnyObject {
    var defaultGarden: Garden {get}
    func cleanup()
    
    
    func addExhibit(name: String, desc: String,lat: Double,long: Double,url: String) -> Exhibit
    func addGarden(name: String) -> Garden
    func addExhibitToGarden(exhibit: Exhibit, garden: Garden) -> Bool
    func deleteExhibit(exhibit: Exhibit)
    func deleteGarden(garden: Garden)
    func removeExhibitFromGarden(exhibit: Exhibit, garden: Garden)
    
    
    func addPlant(name: String, sciName: String, year: Int16, family: String, url: String) -> Plant
    func addPlantToExhibit(plant: Plant, exhibit: Exhibit ) -> Bool
    func deletePlant(plant: Plant)
    func removePlantFromExhibit(plant: Plant, exhibit: Exhibit)
    
 
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
