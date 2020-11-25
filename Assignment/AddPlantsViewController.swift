//
//  AddPlantsViewController.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/12/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class AddPlantsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddPlantDelegate{
   
    
    weak var databaseController: DatabaseProtocol?
    var selectedPlants: [Plant] = []
    var exhibitName: String?
    var exhibitDesc: String?
    var exhhibitLat: Double?
    var exhibitLong: Double?
    
    var editingExhibit: Exhibit?
    var isEditingExhibit: Bool?
    
    
    weak var createExhibit: CreateExhibitViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        editingMode()
    }
    
    // Sets up UI for eding plant
    func editingMode(){
        if isEditingExhibit == true{
            selectedPlants = editingExhibit!.plants?.allObjects as! [Plant]
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPlants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)
        let plant =  self.selectedPlants[indexPath.row]
        cell.textLabel?.text = plant.name
        return cell
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allPlantsSeg" {
            let destination = segue.destination as! AllPlantsTableViewController
            destination.plantDelegate = self
        }
        
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
            selectedPlants.remove(at: indexPath.row)
            tableView.reloadData()
           }
       }
    
     func addPlant(newPlant: Plant) -> Bool {
        if selectedPlants.contains(newPlant){
            return false
        } else {
            selectedPlants.append(newPlant)
            tableView.reloadData()
            return true
        }
    }
    
    
    @IBAction func confirm(_ sender: Any) {
        if selectedPlants.count >= 3 {
            
            var imageURL = "https://www.rbg.vic.gov.au/images/gallery/393/bird_of_paradise_27_oct__large.jpg"
            
            if isEditingExhibit == true {
                imageURL = editingExhibit!.url!
                let _ = databaseController?.deleteExhibit(exhibit: editingExhibit!)
            }
            
            
            let exhibit = databaseController?.addExhibit(name: exhibitName!, desc: exhibitDesc!, lat: exhhibitLat!, long: exhibitLong!, url: imageURL)
            for plant in selectedPlants{
                let _ = databaseController?.addPlantToExhibit(plant: plant, exhibit: exhibit!)
            }
            Items.sharedInstance.isSelected = true
            Items.sharedInstance.value = exhibit!.name!
            
            if isEditingExhibit == true {
                dismiss(animated: true, completion: nil)
            }
            
            Items.sharedInstance.cleanUP = true
            navigationController?.popViewController(animated: false)
            
        } else{
            displayMessage(title: "Add More Plants", message: "Add Atleast three plants to the exhibit")
        }
    }
    
     func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:
            UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
