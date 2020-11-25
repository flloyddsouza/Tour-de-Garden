//
//  ViewController.swift
//  Assignment
//
//  Created by user174137 on 8/25/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//  This controller class controls the mapView vhich is loaded when the app starts.
//  Refered to Week 4 & 5 Tutorial for the code.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, DatabaseListener, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    var allExhibits: [Exhibit] = []
    var annotationList: [LocationAnnotation] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .exhibits
    var geofences: [CLCircularRegion?] = []

    var geofence: CLCircularRegion?
    var locationManager: CLLocationManager = CLLocationManager()
    
    // Listner when exhibits change
    func onExhibitListChange(change: DatabaseChange, exhibits: [Exhibit]) {
        allExhibits = exhibits
        mapView.removeAnnotations(annotationList)
        annotationList.removeAll()
        createAnnotations()
        addLocationToMap()        
    }
    
    
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
        //Doing Nothing
    }

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        Items.sharedInstance.isSelected = false
        Items.sharedInstance.value = "PlaceHolder"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        //Setting Up Region
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: -37.828870, longitude: 144.981037)
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 600, longitudinalMeters: 600)
        mapView.setRegion(region, animated: true)
        
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
    }
    
    // When view will Appear this function will decide if to focus on a Exhibit
    override func viewDidAppear(_ animated: Bool) {
        if Items.sharedInstance.isSelected == true {
            print(Items.sharedInstance.value)
            let foundAnnotation = findAnnotationByName(name: Items.sharedInstance.value)
            focusOn(annotation: foundAnnotation!)
            Items.sharedInstance.isSelected = false
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        locationManager.startUpdatingLocation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    

    // Creating Annotations from Exhibits
    func createAnnotations(){
        for exhibit in allExhibits{
            let location = LocationAnnotation(title: exhibit.name ?? "PlaceHolder", subtitle: exhibit.desc!, lat: exhibit.lat, long: exhibit.long)
            annotationList.append(location)
        }
    }
    
    func findExhibitByName(name: String) -> Exhibit? {
        for exhibit in allExhibits{
            if exhibit.name == name{
                return exhibit
            }
        }
        return nil
    }
    
    
    func findAnnotationByName(name: String) -> LocationAnnotation?{
        for locaion in annotationList{
            if locaion.title == name{
                return locaion
            }
        }
        return nil
    }
    
    // Addig Locations to Map and activating GeoFences
    func addLocationToMap(){
        stopGeoFences()
        geofences.removeAll()
        for location in annotationList{
            mapView.addAnnotation(location)
            geofence = CLCircularRegion(center: location.coordinate, radius: 50, identifier: location.title!)
            geofence?.notifyOnEntry = true
            geofences.append(geofence)
        }
        startGeoFences()
    }
    
    func startGeoFences(){
        for geoloc in geofences {
            locationManager.startMonitoring(for: geoloc!)
        }
    }
    
    func stopGeoFences(){
        for geoloc in geofences {
            locationManager.stopMonitoring(for: geoloc!)
        }
    }
    
    // Custom annotation and view for accessory
    // StackOverflow: https://stackoverflow.com/questions/51717804/mapview-annotation-showing-image-and-title
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.glyphImage = UIImage(named: "Garden_Icon")
        annotationView.canShowCallout = true
        let btn = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = btn
        annotationView.detailCalloutAccessoryView = self.configureDetailView(annotationView: annotationView)
        return annotationView
    }
    
    // Handles user tap on callOutAccessory
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotationTitle = view.annotation?.title
        {
            print("User tapped on annotation with title: \(annotationTitle!)")
            let exhibitionDetailScreen = storyboard?.instantiateViewController(withIdentifier: "exhibit_detail") as! ExhibitDetailViewController
            exhibitionDetailScreen.exhibit = findExhibitByName(name: annotationTitle!)!
            let navController = UINavigationController(rootViewController: exhibitionDetailScreen)
            navigationController?.navigationBar.tintColor = .green
            present(navController, animated: true)
            mapView.deselectAnnotation(view.annotation, animated: true)
        }
    }
    
    // Adding Image To Callout View
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        let image: UIImage = UIImage(named: "Default_Exhibit_Image")!
        let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 112.5))
        imageView.image = image
        view.detailCalloutAccessoryView?.addSubview(imageView)
        let exhibit = findExhibitByName(name: (view.annotation?.title)!!)
        fetchImage(view: view, url: (exhibit?.url)!)
    }
    
    // Configuration of Detail CallOutView Height and Width
    // StackOverFlow - https://stackoverflow.com/questions/33463487/how-to-change-height-of-annotation-callout-window-swift
    func configureDetailView(annotationView: MKAnnotationView) -> UIView {
        let snapshotView = UIView()
        let views = ["snapshotView": snapshotView]
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(113)]", options: [], metrics: nil, views: views))
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(200)]", options: [], metrics: nil, views: views))
        return snapshotView
    }
    
    // Focus on an Annotation.
    func focusOn(annotation: MKAnnotation) {
        //mapView.selectAnnotation(annotation, animated: false)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    
    //Fetching Image
    func fetchImage(view: MKAnnotationView ,url: String){
        guard let url = URL(string: url) else {
            return
        }
        
        let getDataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,error == nil else {
                return
            }
           
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 112.5))
                imageView.image = image
                view.detailCalloutAccessoryView?.addSubview(imageView)
            }
        }
        getDataTask.resume()
    }
    
}

