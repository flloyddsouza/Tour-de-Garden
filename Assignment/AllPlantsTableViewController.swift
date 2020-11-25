//
//  AllPlantsTableViewController.swift
//  Assignment
//
//  Created by Flloyd DSouza on 9/12/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//  Refered to Week 4 Tutorial
//

import UIKit

class AllPlantsTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {

    
    var allPlants: [Plant] = []
    var filteredPlants: [Plant] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .plants
    weak var plantDelegate: AddPlantDelegate?
    
    func onExhibitListChange(change: DatabaseChange, exhibits: [Exhibit]) {
         //Nothing
     }
    
    // Plant Database Listner
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
         allPlants = plants
         updateSearchResults(for: navigationItem.searchController!)
    }
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Plants"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    
    // MARK: - Search Controller Delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
                return
        }

        if searchText.count > 0 {
            filteredPlants = allPlants.filter({ (plant: Plant) -> Bool in
                guard let name = plant.name else {
                    return false
                }
                return name.contains(searchText)
            })
        } else {
            filteredPlants = allPlants
        }
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)
        let plant =  self.allPlants[indexPath.row]
        cell.textLabel?.text = plant.name
        cell.detailTextLabel?.text = plant.sciName
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if plantDelegate?.addPlant(newPlant: filteredPlants[indexPath.row]) ?? false {
            navigationController?.popViewController(animated: true)
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        displayMessage(title: "Already Added", message: "The plant has been already added")
    }
       
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
   
}
