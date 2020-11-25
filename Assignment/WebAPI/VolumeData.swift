//
//  VolumeData.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/16/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
class VolumeData: NSObject, Decodable {
    var plants: [PlantData]?

    private enum CodingKeys: String, CodingKey {
        case plants = "data"
    }
}
