//
//  LocationAnnotation.swift
//  Assignment
//
//  Created by Flloyd Dsouza on 9/4/20.
//  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Copyright © 2020 Monash University. All rights reserved.
//  Class imported from Week 5 Tutorial
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(title: String, subtitle: String, lat: Double, long: Double) {
        self.title = title
        self.subtitle = subtitle
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}
