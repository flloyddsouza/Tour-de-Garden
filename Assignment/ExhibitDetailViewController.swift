//
//  ExhibitDetailViewController.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/4/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//  This controller class controls the ExhibitDetail
//

import UIKit
import MapKit

class ExhibitDetailViewController: UIViewController,MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate{
    
    var exhibit: Exhibit?
    var allPlants: [Plant] = []
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.layer.cornerRadius = 10
        mapView.mapType = .satellite
        titleText.text = exhibit!.name
        descriptionText.text = exhibit!.desc
        allPlants = exhibit!.plants?.allObjects as! [Plant]
        setMap()
    }
    
        
    // Sets the location of exhibit on the map
    func setMap(){
        let exhibitLocation = LocationAnnotation(title: exhibit!.name!, subtitle: "", lat: exhibit!.lat, long: exhibit!.long)
        mapView.addAnnotation(exhibitLocation)
        mapView.selectAnnotation(exhibitLocation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: exhibitLocation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSeg" {
            let destination = segue.destination as! CreateExhibitViewController
            destination.TITLE_TEXT = "Edit Exhibit"
            destination.editingExhibit = exhibit
            destination.isEditingExhibit = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath)
        let plant =  self.allPlants[indexPath.row]
        cell.textLabel?.text = plant.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plantDetailScreen = storyboard?.instantiateViewController(withIdentifier: "plantViewController") as! PlantDetailViewController
        plantDetailScreen.plant = allPlants[indexPath.row]
        self.navigationController?.pushViewController(plantDetailScreen, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
