//
//  CoreDataController.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/3/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//  Code refered from Week 4 Tutorial and modified according to changes.
//  Default Exhibits Images are from https://www.rbg.vic.gov.au/visit-melbourne/attractions/plant-collections//
//  Default Plants Images are from https://trefle.io/


import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    

    let DEFAULT_GARDEN_NAME = "Melbourne Botinical Garadens"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    
    var allExhibitsFetchedResultsController: NSFetchedResultsController<Exhibit>?
    var gardenExhibitsFetchedResultsController: NSFetchedResultsController<Exhibit>?
    var allPlantsFetchResultController: NSFetchedResultsController<Plant>?
    
    
     override init() {
        // Load the Core Data Stack
        persistentContainer = NSPersistentContainer(name: "GardenDataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        super.init()
        if fetchAllExhibits().count == 0 {
            createDefaultEntries()
         }
    }
    
    lazy var defaultGarden: Garden = {
        var gardens = [Garden]()
        
        let request: NSFetchRequest<Garden> = Garden.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", DEFAULT_GARDEN_NAME)
        request.predicate = predicate
       
        do {
            try gardens = persistentContainer.viewContext.fetch(request)
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        
        if gardens.count == 0 {
            return addGarden(name: DEFAULT_GARDEN_NAME)
        }
        
        return gardens.first!
    }()
    
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save to CoreData: \(error)")
            }
        }
    }
    
    
    func cleanup() {
        saveContext()
    }
    
    func addExhibit(name: String, desc: String, lat: Double, long: Double, url: String) -> Exhibit {
        let newExhibit = NSEntityDescription.insertNewObject(forEntityName: "Exhibit",
                                                          into: persistentContainer.viewContext) as! Exhibit
        newExhibit.name = name
        newExhibit.desc = desc
        newExhibit.lat = lat
        newExhibit.long = long
        newExhibit.url = url
        return newExhibit
    }
    
    
    func addGarden(name: String) -> Garden {
        let garden = NSEntityDescription.insertNewObject(forEntityName: "Garden",
                                                       into: persistentContainer.viewContext) as! Garden
        garden.name = name
        return garden
    }
    
    
    func addExhibitToGarden( exhibit: Exhibit, garden: Garden) -> Bool {
        guard let exhibits = garden.exhibits, exhibits.contains(exhibit) == false else {
            return false
        }
        garden.addToExhibits(exhibit)
        return true
    }
    
    func addPlant(name: String, sciName: String, year: Int16, family: String, url: String ) -> Plant {
        let newPlant = NSEntityDescription.insertNewObject(forEntityName: "Plant", into: persistentContainer.viewContext) as! Plant
        newPlant.name = name
        newPlant.sciName = sciName
        newPlant.year = year
        newPlant.family = family
        newPlant.url = url
        return newPlant
    }
       
    func addPlantToExhibit(plant: Plant, exhibit: Exhibit) -> Bool {
        guard let plants = exhibit.plants, plants.contains(plant) == false else {
            return false
        }
        exhibit.addToPlants(plant)
        return true
    }
    
    
    func deleteExhibit(exhibit: Exhibit) {
        persistentContainer.viewContext.delete(exhibit)
    }
    
    func deleteGarden(garden: Garden) {
        persistentContainer.viewContext.delete(garden)
    }
    
    func removeExhibitFromGarden(exhibit: Exhibit, garden: Garden) {
        garden.removeFromExhibits(exhibit)
    }
    
    func deletePlant(plant: Plant) {
        persistentContainer.viewContext.delete(plant)
    }
    
    func removePlantFromExhibit(plant: Plant, exhibit: Exhibit) {
        exhibit.removeFromPlants(plant)
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .exhibits || listener.listenerType == .all {
            listener.onExhibitListChange(change: .update, exhibits: fetchAllExhibits())
        }
        
        if listener.listenerType == .plants || listener.listenerType == .all {
            listener.onPlantListChange(change: .update, plants: fetchAllPlants())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allExhibitsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .exhibits || listener.listenerType == .all {
                    listener.onExhibitListChange(change: .update, exhibits: fetchAllExhibits())
                }
            }
        }
        
        if controller == allPlantsFetchResultController {
            listeners.invoke { (listener) in
                if listener.listenerType == .plants || listener .listenerType == .all{
                    listener.onPlantListChange(change: .update, plants: fetchAllPlants())
                }
                
            }
        }
        
    }
    
    
    func fetchAllExhibits() -> [Exhibit]{
         if allExhibitsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Exhibit> = Exhibit.fetchRequest()
            // Sort by name
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
 
            // Initialize Results Controller
            allExhibitsFetchedResultsController = NSFetchedResultsController<Exhibit>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
 
            // Set this class to be the results delegate
            allExhibitsFetchedResultsController?.delegate = self

            do {
                try allExhibitsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }

        var exhibits = [Exhibit]()
        if allExhibitsFetchedResultsController?.fetchedObjects != nil {
            exhibits = (allExhibitsFetchedResultsController?.fetchedObjects)!
        }

        return exhibits
        
    }
    
    
    func fetchAllPlants() -> [Plant]{
        if allPlantsFetchResultController == nil {
            let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            
            allPlantsFetchResultController = NSFetchedResultsController<Plant>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            allPlantsFetchResultController?.delegate = self
            do {
                try allPlantsFetchResultController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        var plants = [Plant]()
        if allPlantsFetchResultController?.fetchedObjects != nil {
            plants = (allPlantsFetchResultController?.fetchedObjects)!
        }
        return plants
    }
    
    
    
    func fetchGardenExhibits() -> [Exhibit]{
         if gardenExhibitsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Exhibit> = Exhibit.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let predicate = NSPredicate(format: "ANY gardens.name == %@", DEFAULT_GARDEN_NAME)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate

            gardenExhibitsFetchedResultsController = NSFetchedResultsController<Exhibit>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            gardenExhibitsFetchedResultsController?.delegate = self

            do {
                try gardenExhibitsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }

        var exhibits = [Exhibit]()
        if gardenExhibitsFetchedResultsController?.fetchedObjects != nil {
            exhibits = (gardenExhibitsFetchedResultsController?.fetchedObjects)!
        }

        return exhibits
        
    }

    func createDefaultEntries(){
        let ex1 = addExhibit(name: "Bamboo Collection", desc: "A key objective of the Bamboo collection is to highlight the significant ethnobotanical uses of bamboo and grasses and the vital role they contribute to for life on earth and highlights the threats to grass biodiversity and biomes they support", lat: -37.830530, long: 144.980224, url: "https://www.rbg.vic.gov.au/images/gallery/3003/bamboo_photo_by_chazel__large.jpg")

        let ex2 = addExhibit(name: "Cycad Collection", desc: "Slow growing plants, palm like in appearance but classified in a distinct group. Plants are either female or male and produce cones containing either seed or pollen. Cycads are gymnosperms.", lat: -37.830978, long: 144.982552, url: "https://www.rbg.vic.gov.au/images/gallery/283/macrozamia__large.jpg")

        let ex3 = addExhibit(name: "Fern Gully", desc: "The Fern Gully is a natural gully within the gardens providing a perfect micro climate for ferns. Visitors can follow a stream via the winding paths in the cool surrounds under the canopy of lush tree ferns.", lat: -37.831437, long: 144.980454, url: "https://www.rbg.vic.gov.au/images/gallery/303/fern-gully---lo-res-2__large.jpg")

        let ex4 = addExhibit(name: "Herb Garden", desc: "A wide range of herbs from well known leafy annuals such as Basil and Coriander, to majestic mature trees such as the Camphor.The large trees are remnants from the original 1890s Medicinal Garden.", lat: -37.831527, long: 144.979346, url: "https://www.rbg.vic.gov.au/images/gallery/323/img_1075__large.jpg")


        let ex5 = addExhibit(name: "Gardens House", desc: "A garden within a garden, the Garden House display garden is an enclosed area surrounding historic Gardens House. The aim of this collection is to highlight the horticultural display of a heritage landscape.", lat: -37.829951, long: 144.978194, url: "https://www.rbg.vic.gov.au/images/gallery/2839/picture_010__large.jpg")

        let ex6 = addExhibit(name: "Lower Yarra River Habitat", desc: "An ecological collection to display and conserve Indigenous plants from five plant communities found locally in the lower Yarra region.This area has been transformed to display a significant collection of five Indigenous plant communities.", lat: -37.827995, long: 144.979982, url: "https://www.rbg.vic.gov.au/images/gallery/333/acacia__large.jpg")

        let ex7 = addExhibit(name: "Oak Collection", desc: "The great trees of Melbourne Gardens are spectacular throughout the year, but autumn is a particularly special time when the elms, oaks, and many other deciduous trees explode into a mass of vibrant yellow, red and orange.", lat: -37.831076, long: 144.977966, url: "https://www.rbg.vic.gov.au/images/gallery/353/autumn_colour__large.jpg")


        let ex8 = addExhibit(name: "Palms Collection", desc: "Around 40 different species of palms are grown here at the Gardens. They are mainly from cooler temperate areas, but there are some surprising exceptions. However, here individually they have found a home.", lat: -37.831340, long: 144.980900, url: "https://www.rbg.vic.gov.au/images/gallery/363/livistona_australis__large.jpg")


        let ex9 = addExhibit(name: "Tropical Glasshouse", desc: "The Tropical Glasshouse at Melbourne Gardens showcases plants from tropical regions around the globe, and displays some of the most important and spectacular tropical rainforest plants known to man.", lat: -37.832026, long: 144.979709, url: "https://www.rbg.vic.gov.au/images/gallery/2825/titan-arum-lo__large.jpg")

        let ex10 = addExhibit(name: "Species Rose Collection", desc: "With more than 100 different species and varieties of roses the collection at Melbourne Gardens always has something to offer. Come in spring to see species roses from the northern hemisphere and cultivars bred both here in Australia and overseas in flower.", lat: 37.830670, long: 144.983303, url: "https://www.rbg.vic.gov.au/images/gallery/423/884__large.jpg")
 
        //Exhibit 1
        var p1 = addPlant(name: "Black bamboo", sciName: "Phyllostachys nigra", year: 1868, family: "Poaceae", url: "https://bs.floristic.org/image/o/45e7e42c5f9b0a9ec324b9fba3abf970bcfe8ded")

        var p2 = addPlant(name: "Bukkup", sciName: "Xanthorrhoea australis", year: 1810, family: "Asphodelaceae",url: "https://bs.floristic.org/image/o/c7cd883fcc0bff8642add1dabdb3eac835447a15")

        var p3 = addPlant(name: "Kangaroo grass", sciName: "Themeda triandra", year: 1775, family: "Poaceae",url: "https://bs.floristic.org/image/o/6d61499ca83f5571b2c8a61d5c6190263404b891")

        let _ = addPlantToExhibit(plant: p1, exhibit: ex1)
        let _ = addPlantToExhibit(plant: p2, exhibit: ex1)
        let _ = addPlantToExhibit(plant: p3, exhibit: ex1)



        //Exhibit 2
        p1 = addPlant(name: "Burrawong", sciName: "Macrozamia communis", year: 1959, family: "Zamiaceae",url: "https://bs.floristic.org/image/o/8e4919e4f3f9d5ba3b0a4eadd499bb77e0e4e6f2")

        p2 = addPlant(name: "Prickly cycad", sciName: "Encephalartos altensteinii", year: 1834, family: "Zamiaceae",url: "https://bs.floristic.org/image/o/f31e8668c8fc36bf9fb2a1a422def33c8a00c6b1")

        p3 = addPlant(name: "Cycad", sciName: "Ceratozamia mexicana", year: 1846, family: "Zamiaceae",url: "https://bs.floristic.org/image/o/263c5f3d11bce828148a2cd0b6bacfcfdf7a355a")

        let _ = addPlantToExhibit(plant: p1, exhibit: ex2)
        let _ = addPlantToExhibit(plant: p2, exhibit: ex2)
        let _ = addPlantToExhibit(plant: p3, exhibit: ex2)

        //Exhibit 3
        p1 = addPlant(name: "Bird's Nest Fern", sciName: "Asplenium australasicum", year: 1858, family: "Aspleniaceae",url: "http://d2seqvvyy3b8p2.cloudfront.net/263eae20a3ffcf84f05a157eee7b64fe.jpg")

        p2 = addPlant(name: "Fishbone Water Fern", sciName: "Blechnum nudum", year: 1943, family: "Aspleniaceae",url: "https://bs.floristic.org/image/o/93d7e4950c203063b83cce9ca9151561cdb1c3d5")

        p3 = addPlant(name: "Soft Tree Fern", sciName: "Dicksonia antarctica", year: 1806, family: "Cyatheaceae",url: "http://storage.googleapis.com/powop-assets/kew_profiles/Screen%20Shot%202014-04-15%20at%202.05.33%20PM_fullsize.jpg")

        let _ = addPlantToExhibit(plant: p1, exhibit: ex3)
        let _ = addPlantToExhibit(plant: p2, exhibit: ex3)
        let _ = addPlantToExhibit(plant: p3, exhibit: ex3)

        //Exhibit 4
        p1 = addPlant(name: "Rock Samphire", sciName: "Crithmum maritimum", year: 1753, family: "Apiaceae",url: "http://d2seqvvyy3b8p2.cloudfront.net/5e77f69531d6c1aafe28520b33dfa513.jpg")

        p2 = addPlant(name: "Japanese camphor", sciName: "Cinnamomum camphora", year: 1857, family: "Lauraceae",url: "https://bs.floristic.org/image/o/912a931c12bbf9f6531c6439bee26a4c293d2b06")

        p3 = addPlant(name: "Bay Tree", sciName: "Laurus nobilis", year: 1753, family: "Lauraceae",url: "https://bs.floristic.org/image/o/c60e9ebb436b5dd6083a0cfdc6946b3f3b2a1353")

        let _ = addPlantToExhibit(plant: p1, exhibit: ex4)
        let _ = addPlantToExhibit(plant: p2, exhibit: ex4)
        let _ = addPlantToExhibit(plant: p3, exhibit: ex4)


        //Exhibit 5

        p1 = addPlant(name: "Queensland-pine", sciName: "Araucaria bidwilli", year: 1843, family: "Araucariaceae",url: "https://bs.floristic.org/image/o/9b75fdd616d80a45c65587cb7ef54018f835b824")

        p2 = addPlant(name: "Eastern cottonwood", sciName: "Populus deltoides", year: 1785, family: "Salicaceae",url: "https://bs.floristic.org/image/o/994b792bfe110810897eb015be83fd0d85f26991")

        p3 = addPlant(name: "Texas madrone", sciName: "Arbutus glandulosa", year: 1819, family: "Arbutus",url: "https://bs.floristic.org/image/o/44b2dda4f03259e600204db1ac33ceed3408b53c")

        let _ = addPlantToExhibit(plant: p1, exhibit: ex5)
        let _ = addPlantToExhibit(plant: p2, exhibit: ex5)
        let _ = addPlantToExhibit(plant: p3, exhibit: ex5)

        //Exhibit 6

        p1 = addPlant(name: "Tufted Perennial grass", sciName: "Rytidosperma geniculatum", year: 1979, family: "Poaceae",url: "http://d2seqvvyy3b8p2.cloudfront.net/080eea7523df7d04e0ecb7efc6807174.jpg")

        p2 = addPlant(name: "Rock Correa", sciName: "Correa glabra", year: 1838, family: "Rutaceae",url: "https://bs.floristic.org/image/o/e6d50c9668da130ae4d315a167539b56af7206dd")

        p3 = addPlant(name: "Austral Storks-bill", sciName: "Pelargonium australe", year: 1800, family: "Geraniaceae",url: "http://d2seqvvyy3b8p2.cloudfront.net/a39c028e24a455bee330142e0f996092.jpg")
        
        let _ = addPlantToExhibit(plant: p1, exhibit: ex6)
        let _ = addPlantToExhibit(plant: p2, exhibit: ex6)
        let _ = addPlantToExhibit(plant: p3, exhibit: ex6)
        
        //Exhibit 7
        p1 = addPlant(name: "Algerian oak", sciName: "Quercus canariensis", year: 1809, family: "Fagaceae",url: "https://bs.floristic.org/image/o/0718714bdba14b284dbf10f05e249bb7489b8467")

        p2 = addPlant(name: "Evergreen Oak", sciName: "Quercus ilex", year: 1785, family: "Fagaceae",url: "https://bs.floristic.org/image/o/1a03948baf0300da25558c2448f086d39b41ca30")

        p3 = addPlant(name: "Scarlet oak", sciName: "Quercus coccinea", year: 1770, family: "Fagaceae",url: "https://bs.floristic.org/image/o/3e96f72186e9cdaedba5b01bab2d247aa35f3791")
        
        let _ = addPlantToExhibit(plant: p1, exhibit: ex7)
        let _ = addPlantToExhibit(plant: p2, exhibit: ex7)
        let _ = addPlantToExhibit(plant: p3, exhibit: ex7)
        
        
        //Exhibit 8
        p1 = addPlant(name: "Canary Island date palm", sciName: "Phoenix canariensis", year: 1882, family: "Arecaceae",url: "https://bs.floristic.org/image/o/eea464da66b31d3f39371a80b2a2ee2f691faab9")

        p2 = addPlant(name: "Bangalow Palm", sciName: "Archontophoenix cunninghamiana", year: 1875, family: "Arecaceae",url: "https://bs.floristic.org/image/o/519ba5393b372c3ccc72a40302c455715ebde750")

        p3 = addPlant(name: "Australian cabbage palm", sciName: "Livistona australis", year: 1838, family: "Arecaceae",url: "https://bs.floristic.org/image/o/f76f421b9cc49b371d3a6a1d14192a7eaec01aa5")

        let _ = addPlantToExhibit(plant: p1, exhibit: ex8)
        let _ = addPlantToExhibit(plant: p2, exhibit: ex8)
        let _ = addPlantToExhibit(plant: p3, exhibit: ex8)
        
        // Exhibit 9

        p1 = addPlant(name: "Titan arum", sciName: "Amorphophallus titanum", year: 1879, family: "Araceae",url: "https://bs.floristic.org/image/o/0b91dd94ae0a9a615155fd236db95512c5bc64ea")

        p2 = addPlant(name: "Cycad", sciName: "Ceratozamia mexicana", year: 1846, family: "Zamiaceae",url: "https://bs.floristic.org/image/o/263c5f3d11bce828148a2cd0b6bacfcfdf7a355a")

        p3 = addPlant(name: "Tiger-spotted Stanhopea", sciName: "Stanhopea tigrina", year: 1838, family: "Orchidaceae",url: "https://bs.floristic.org/image/o/16cd867da29fe3d05b5180c10477ce0e483b2dd8")

        let _ = addPlantToExhibit(plant: p1, exhibit: ex9)
        let _ = addPlantToExhibit(plant: p2, exhibit: ex9)
        let _ = addPlantToExhibit(plant: p3, exhibit: ex9)
        
        // Exhibit 10

        p1 = addPlant(name: "Yellow rose", sciName: "Rosa xanthina", year: 1820, family: "Rosaceae",url: "https://bs.floristic.org/image/o/6416eb252e4e3d359aa298647c1568ed8ad03b90")

        p2 = addPlant(name: "Chestnut rose", sciName: "Rosa roxburghii", year: 1823, family: "Rosaceae",url: "https://bs.floristic.org/image/o/2d6c25e69331c645e31cc46d9f8f8e3b2a2090c0")

        p3 = addPlant(name: "Rugosa rose", sciName: "Rosa rugosa", year: 1784, family: "Rosaceae",url: "https://bs.floristic.org/image/o/fe957b1a87df808443782ad72c2c0ddec0729370")

        let _ = addPlantToExhibit(plant: p1, exhibit: ex10)
        let _ = addPlantToExhibit(plant: p2, exhibit: ex10)
        let _ = addPlantToExhibit(plant: p3, exhibit: ex10)    }
}
