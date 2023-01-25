//
//  LocationData.swift
//  ForaBank
//
//  Created by Max Gribov on 12.04.2022.
//

import Foundation
import CoreLocation

struct LocationData: Equatable {
    
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
        
        let stringDataAdjusted = stringData.replacingOccurrences(of: " ", with: "")
        let coordinateData = stringDataAdjusted.split(separator: ",")
        
        guard coordinateData.count == 2,
              let latitude = CLLocationDegrees(coordinateData[0]),
              let longitude =  CLLocationDegrees(coordinateData[1]) else {
            
            throw LocationDataError.unableDecodeLocationFromString(stringData)
        }
        
        self.init(latitude: latitude, longitude: longitude)
    }
    
    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    var stringValue: String { "\(latitude),\(longitude)" }
}

extension LocationData: Codable {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        try self.init(with: stringValue)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}

enum LocationDataError: LocalizedError {
    
    case unableDecodeLocationFromString(String)
    
    var errorDescription: String? {
        
        switch self {
        case let .unableDecodeLocationFromString(value):
            return "Unable decode location from string: \(value)"
        }
    }
}

