//
//  AtmRadius.swift
//  ForaBank
//
//  Created by Max Gribov on 12.04.2022.
//

import Foundation
import CoreLocation

struct AtmRadius {
    
    let location: CLLocationCoordinate2D
    let radius: CLLocationDistance
    
    var radiusTitle: String {
        
        NumberFormatter.distance.string(fromMeters: radius)
    }
    
    static let sample = AtmRadius(location: .moscow, radius: 5000)
}
