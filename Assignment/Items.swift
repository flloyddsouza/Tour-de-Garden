//
//  Items.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/8/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//  This class is uded to share data throughout the app.
//

import Foundation
class Items {
    static let sharedInstance = Items()
    var isSelected = Bool()
    var value = String()
    var cleanUP = Bool()
}
