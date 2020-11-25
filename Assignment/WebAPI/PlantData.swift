//
//  PlantData.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/16/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
class PlantData: NSObject, Decodable {
    var name: String?
    var sciName: String?
    var year: Int?
    var family: String?
    var url: String?

    private enum RootKeys: String, CodingKey {
        case name = "common_name"
        case sciName = "scientific_name"
        case year
        case family
        case url = "image_url"
    
    }

    required init(from decoder: Decoder) throws {
        let cardContainer = try decoder.container(keyedBy: RootKeys.self)
        name = try? cardContainer.decode(String.self, forKey: .name)
        sciName = try? cardContainer.decode(String.self, forKey: .sciName)
        year =  try? cardContainer.decode(Int.self, forKey: .year)
        family =  try? cardContainer.decode(String.self, forKey: .family)
        url = try? cardContainer.decode(String.self, forKey: .url)
    }
}
