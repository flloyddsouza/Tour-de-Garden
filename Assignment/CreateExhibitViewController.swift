//
//  CreateExhibitViewController.swift
//  Assignment
//
//  Created by user174137 on 9/11/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//  LongPress for Annotation: StackOverFlow :https://stackoverflow.com/questions/40844336/create-long-press-gesture-recognizer-with-annotation-pin
//  Keyboard Handling: https://fluffy.es/move-view-when-keyboard-is-shown/

import UIKit
import MapKit
import CoreData

class CreateExhibitViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    
    var TITLE_TEXT = "New Exhibit"
    let locationManager = CLLocationManager()
   
    @IBOutlet weak var map: MKMapView!
    var addedLocation: MKPointAnnotation?
    
    //TextFields
    
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var descTextField: UITextView!
    
    //Error Labels
    @IBOutlet weak var mapError: UILabel!
    @IBOutlet weak var nameError: UILabel!
    @IBOutlet weak var descriptionError: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeTextField : UITextField? = nil
    weak var databaseController: DatabaseProtocol?
    
    var editingExhibit: Exhibit?
    var isEditingExhibit: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.layer.cornerRadius = 10
        
        NameTextField.delegate = self
        descTextField.delegate = self
    
        descTextField.layer.cornerRadius = 5
        descTextField.layer.borderColor = UIColor.lightGray.cgColor
        descTextField.layer.borderWidth = 0.5
        descTextField.text = "Enter Description here."
        descTextField.textColor = .lightGray
        
        
        // Database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        
        // add gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(CreateExhibitViewController.mapLongPress(_:)))
        longPress.minimumPressDuration = 1.2 // in seconds
        map.addGestureRecognizer(longPress)
        
        //Region for MapView
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude:  -37.827836, longitude: 144.9780736)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        map.setRegion(map.regionThatFits(zoomRegion), animated: true)
        
        
        //TextField Error and Keyboard Handling
        NameTextField.addTarget(self, action: #selector(nameValidator(textField:)), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        checkLocationServices()
        editingMode()
        
    }

    // Setting Up UI for Editing a Exhibit
    func editingMode(){
        if isEditingExhibit == true {
            self.navigationItem.title = TITLE_TEXT
            NameTextField.text = editingExhibit?.name
            descTextField.text = editingExhibit?.desc
            if self.traitCollection.userInterfaceStyle == .dark {
                descTextField.textColor = .white
            } else {
                descTextField.textColor = .black
            }
            nextButton.setTitle("Next", for: .normal)
            
            addedLocation = MKPointAnnotation()
            addedLocation?.coordinate = CLLocationCoordinate2D(latitude: editingExhibit!.lat, longitude: editingExhibit!.long)
            map.addAnnotation(addedLocation!)
            
            let zoomRegion = MKCoordinateRegion(center: addedLocation!.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
            map.setRegion(map.regionThatFits(zoomRegion), animated: true)
            
        }
    }
    

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
            self.navigationItem.title = TITLE_TEXT
        }
    }
  
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let topOfKeyboard = self.view.frame.height - keyboardSize.height
        var bottOfField: CGFloat
        
        if let activeTextField = activeTextField {
            bottOfField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
        } else {
            bottOfField = descTextField.convert(descTextField.bounds, to: self.view).maxY;
        }
        
        if bottOfField > topOfKeyboard {
            self.navigationItem.title = ""
            self.view.frame.origin.y = 0 - (bottOfField - topOfKeyboard + 40)
        }
    }
 
    
    //LongPress To add Location
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        if addedLocation != nil{
            map.removeAnnotation(addedLocation!)
        }
        let touchedAt = recognizer.location(in: self.map) // adds the location on the view it was pressed
        let touchedAtCoordinate : CLLocationCoordinate2D = map.convert(touchedAt, toCoordinateFrom: self.map) // will get coordinates
        addedLocation = MKPointAnnotation()
        addedLocation!.coordinate = touchedAtCoordinate
        map.addAnnotation(addedLocation!)
        mapError.text = ""
    }


    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addPlantsSeg"{
           return validator()
        }
        return false
    }
    
    // Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlantsSeg" {
            let destination = segue.destination as! AddPlantsViewController
            destination.exhibitName = NameTextField.text
            destination.exhibitDesc = descTextField.text
            destination.exhhibitLat = addedLocation?.coordinate.latitude ?? 0.01
            destination.exhibitLong = addedLocation?.coordinate.longitude ?? 0.01
            if isEditingExhibit == true {
                destination.editingExhibit = editingExhibit
                destination.isEditingExhibit = true
            }
        }
    }
    
    // MARK: - Real Time Validators
    
    @objc func nameValidator(textField: UITextField){
        if textField.text?.count == 0{
            nameError.text = "Exhibit Name connot be Empty"
        }else if textField.text?.count ?? 0 < 4 {
            nameError.text = "Exhibit Name should be greater than 4 characters"
        }
        else {
            nameError.text = ""
        }
    }
    
    @objc func descValidator(textField: UITextField){
           if textField.text?.count == 0{
               descriptionError.text = "Description connot be Empty"
           }else if textField.text?.count ?? 0 < 25 {
               descriptionError.text = "Description should be greater than 25 characters"
           }
           else {
               descriptionError.text = ""
           }
    }
    
    
    // MARK: - Handling First Responder for TextField and TextView
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        if (textView.text == "Enter Description here." && textView.textColor == .lightGray){
            if self.traitCollection.userInterfaceStyle == .dark {
                textView.textColor = .white
            } else {
                textView.textColor = .black
            }
            textView.text = ""
            
        }
        textView.becomeFirstResponder() //Optional
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == ""){
            textView.text = "Enter Description here."
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    // Validation for TextFields and MapLocation
    func  validator() -> Bool{
        
        var valid: Bool = true
        
        if NameTextField.text?.count ?? 0 == 0 {
            nameError.text = "Exhibit Name connot be Empty"
            valid = false
        } else if NameTextField.text?.count ?? 0 < 4 {
            nameError.text = "Exhibit Name should be greater than 4 characters"
            valid =  false
        }
        
        if descTextField.text?.count ?? 0 == 0 {
            descriptionError.text = "Description connot be Empty"
            valid = false
        } else if descTextField.text?.count ?? 0 < 25 {
            descriptionError.text = "Description should be greater than 25 characters"
            valid =  false
        }
        
        if addedLocation?.coordinate == nil {
            mapError.text = "Select Location on the Map"
            valid =  false
        }
        
        
        return valid
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Items.sharedInstance.cleanUP == true {
            cleanUp()
        }
    }
    
    
    // Cleaning Text Fields after sucessfull creation of Exhibit
    func cleanUp(){
        Items.sharedInstance.cleanUP = false
        NameTextField.text = ""
        descTextField.text = ""
        map.removeAnnotation(addedLocation!)
        addedLocation = nil
        self.tabBarController?.selectedIndex = 0
    }
    
    
    
    
    // MARK: - User Location on Map & Permissions
    // From: https://www.youtube.com/watch?v=WPpaAy73nJc
    
    func centreViewOnLocation(){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location,latitudinalMeters: 400, longitudinalMeters:  400)
            map.setRegion(region, animated: true)
        }
    }
    
    func setUPLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setUPLocationManager()
            checkLocationAuthorisation()
        }
    }
    
    
    func checkLocationAuthorisation(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            map.showsUserLocation = true
             centreViewOnLocation()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            map.showsUserLocation = true
            centreViewOnLocation()
            break
        @unknown default:
            break
        }
    }
    

    
}
