//
//  SearchPlantsTableViewController.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/16/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//  Reffered to Week 6 Tutorail
//

import UIKit

class SearchPlantsTableViewController: UITableViewController ,UISearchBarDelegate, DatabaseListener {
   
    var indicator = UIActivityIndicatorView()
    var newPlants = [PlantData]()
    var allPlants = [Plant]()
    var listenerType: ListenerType = .plants
    let REQUEST_STRING = "https://trefle.io/api/v1/plants/search?token=-0hMRmh2QoEK29_goWkiQkgKZsfBYX41cXdQxNgEDfQ&q="
    weak var databaseController: DatabaseProtocol?
    
    
    func onExhibitListChange(change: DatabaseChange, exhibits: [Exhibit]) {
        //Nothing
    }
    
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
        allPlants = plants
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Online for Plants"

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
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
        return newPlants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)
        let plant = newPlants[indexPath.row]
        cell.textLabel?.text = plant.name
        cell.detailTextLabel?.text = plant.family
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let plant = newPlants[indexPath.row]
        
        if containsPlant(plantName: plant.name!){
            tableView.deselectRow(at: indexPath, animated: true)
            displayMessage(title: "Already Exists", message: "The plant already exists!")
        }else
        {
            let name = plant.name!
            let sciName =  plant.sciName ?? "Not Found"
            let year = plant.year ?? 1800
            let family = plant.family ?? "Not Found"
            let url = plant.url ?? "Not Found"
            let newPlant = databaseController?.addPlant(name: name, sciName: sciName, year: Int16(year), family: family, url: url)
            print(newPlant!)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func containsPlant(plantName: String) -> Bool{
        for plant in allPlants{
            if plant.name == plantName{
                return true
            }
        }
        return false
    }
    
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // If there is no text end immediately
        guard let searchText = searchBar.text, searchText.count > 0 else {
            return;
        }

        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear

        newPlants.removeAll()
        tableView.reloadData()
        requestPlants(plantName: searchText)
    }
    
    func requestPlants(plantName: String) {
        let searchString = REQUEST_STRING + plantName
        let jsonURL = URL(string: searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)

        let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
            // Regardless of response end the loading icon from the main thread
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }

            if let error = error {
                print(error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let volumeData = try decoder.decode(VolumeData.self, from: data!)
                if let plants = volumeData.plants {
                    self.newPlants.append(contentsOf: plants)

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch let err {
                print(err)
            }
        }

        task.resume()
    }
}
