//
//  PlantDetailViewController.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/9/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class PlantDetailViewController: UIViewController {

    var plant: Plant?
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var sciNameText: UILabel!
    @IBOutlet weak var yearText: UILabel!
    @IBOutlet weak var familyText: UILabel!
    @IBOutlet weak var plantImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(plant!)
        plantImage.layer.cornerRadius = 10
        nameText.text = plant!.name
        sciNameText.text = "                 \(plant!.sciName ?? "Not Found")"
        yearText.text = "Year Discovered: \(String(plant!.year))"
        familyText.text = "Family: \(plant!.family ?? "Not Found")"
        fetchImage()
    }
   
    
   // Fetching image from URL
   func fetchImage(){
    guard let url = URL(string:plant!.url!) else {
            return
        }
        let getDataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image =  UIImage(data: data)
                self.plantImage.image = image
            }
        }
        getDataTask.resume()
    }
}
