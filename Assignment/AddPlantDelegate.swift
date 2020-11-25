//
//  AddPlantDelegate.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/12/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
protocol AddPlantDelegate: AnyObject {
 func addPlant(newPlant: Plant) -> Bool
}
