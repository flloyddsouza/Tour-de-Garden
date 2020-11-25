//
//  AllExhibitsTableTableViewController.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/4/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//  Refered to Code from Week 4 Tutorial
//

import UIKit

class AllExhibitsTableTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {
    
    
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
        //do nothing
    }
    
    var allExhibits: [Exhibit] = []
    var filteredExhibits: [Exhibit] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .exhibits
    var deleteExhibitIndexPath: Int? = nil
    var sort: Bool?
    
    
    // Exhibit change Listner
    func onExhibitListChange(change: DatabaseChange, exhibits: [Exhibit]) {
        if sort == true{
            allExhibits = exhibits.reversed()
        }else{
        allExhibits = exhibits
        }
        updateSearchResults(for: navigationItem.searchController!)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        filteredExhibits = allExhibits
        sort = false

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Exhibits"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Search Controller Delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
                return
        }

        if searchText.count > 0 {
            filteredExhibits = allExhibits.filter({ (exhibit: Exhibit) -> Bool in
                guard let name = exhibit.name else {
                    return false
                }
                return name.contains(searchText)
            })
        } else {
            filteredExhibits = allExhibits
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
        return filteredExhibits.count
    }

 
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "exhibitCell", for: indexPath)
        let exhibit =  self.allExhibits[indexPath.row]
        cell.textLabel?.text = exhibit.name
        cell.detailTextLabel?.text = exhibit.desc
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exhibit = self.allExhibits[indexPath.row]
        Items.sharedInstance.isSelected = true
        Items.sharedInstance.value = exhibit.name!
        self.tabBarController?.selectedIndex = 0
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteExhibitIndexPath = indexPath.row
            confirmDelete(exhibitName: allExhibits[indexPath.row].name!)
        }
    }
    

    func confirmDelete( exhibitName: String) {
        let alert = UIAlertController(title: "Delete Exhibit", message: "Are you sure you want to permanently delete \(exhibitName)", preferredStyle: .alert)
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteExhibit)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteExhibit)
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        self.present(alert, animated: true, completion: nil)
   }
    
    func handleDeleteExhibit(alertAction: UIAlertAction!) -> Void {
        self.databaseController!.deleteExhibit(exhibit: allExhibits[deleteExhibitIndexPath!])
        
    }
    
    func cancelDeleteExhibit(alertAction: UIAlertAction!) {
        deleteExhibitIndexPath = nil
    }
    
    // Sort By Button Handling
    @IBAction func sortBy(_ sender: Any) {
        let alert = UIAlertController(title: "Sort Exhibits By", message: nil, preferredStyle: .alert)
        let AscAction = UIAlertAction(title: "Ascending", style: .default, handler: handleAssending)
        let DescAction = UIAlertAction(title: "Descending", style: .default, handler: handleDescending)
        alert.addAction(AscAction)
        alert.addAction(DescAction)
        self.present(alert,animated: true,completion: nil)
    }
    
    // Asscending Sort fuunction
    func handleAssending(alertAction: UIAlertAction!) -> Void{
        if sort == true{
            allExhibits = allExhibits.reversed()
            sort =  false
            tableView.reloadData()
        }
    }
    
    // Descending Sort Function
    func handleDescending(alertAction: UIAlertAction!) -> Void{
        if sort == false{
            allExhibits =  allExhibits.reversed()
            sort =  true
            tableView.reloadData()
        }
    }
    
}
