//
//  LocationData.swift
//  ForaBank
//
//  Created by Max Gribov on 12.04.2022.
//

import Foundation
import CoreLocation

struct LocationData {
    
    let latitude: Double
    let longitude: Double
    
    internal init(latitude: Double, longitude: Double) {
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(with coordinate: CLLocationCoordinate2D) {
        
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    init(with stringData: String) throws {
        
        let coordinateData = stringData.split(separator: ",")
        
        guard coordinateData.count == 2,
              let latitude = CLLocationDegrees(coordinateData[0]),
              let longitude =  CLLocationDegrees(coordinateData[1]) else {
            
            throw LocationDataError.unableDecodeLocationFromStringData
        }
        
        self.init(latitude: latitude, longitude: longitude)
    }
    
    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
}

enum LocationDataError: Error {
    
    case unableDecodeLocationFromStringData
}

