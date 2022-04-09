//
//  AtmData.swift
//  ForaBank
//
//  Created by Max Gribov on 04.04.2022.
//

import Foundation
import CoreLocation
import SwiftUI

struct AtmData: Identifiable, Codable, Equatable, Cachable {
    
    let id: String
    let name: String
    let type: Int
    let serviceIdList: [Int]
    let metroStationList: [Int]
    let region: String
    let city: String
    let address: String
    let schedule: String
    let location: String
    let email: String
    let phoneNumber: String
    let action: Action
    
    var servicesListSet: Set<Int> { Set(serviceIdList) }
    
    enum CodingKeys : String, CodingKey, Decodable {
        
        case id = "xmlId"
        case name, type, serviceIdList, metroStationList, region, city, address, schedule, location, email, phoneNumber, action
    }
}

extension AtmData {
    
    enum Action: String, Codable {
        
        case insert = "INSERT"
        case update = "UPDATE"
        case delete = "DELETE"
    }
    
    enum Category: Int, CaseIterable {
        
        case office
        case atm
        case terminal
        
        var icon: Image {
            
            switch self {
            case .office: return .ic16Bank
            case .atm: return .ic16Cash
            case .terminal: return .ic16Tablet
            }
        }
        
        var name: String {
            
            switch self {
            case .office: return "Отделения"
            case .atm: return "Банкоматы"
            case .terminal: return "Терминалы"
            }
        }
        
        var types: [Int] {
            
            switch self {
            case .atm: return [1, 34]
            case .terminal: return [33, 35, 36]
            default:
                return [9]
            }
        }
    }
}

extension AtmData {
    
    var category: Category {
        
        switch type {
        case 1, 34: return .atm
        case 33, 35, 36: return .terminal
        default:
            return .office
        }
    }
    
    var coordinate: CLLocationCoordinate2D? {
        
        let coordinateData = location.split(separator: ",")
        
        guard coordinateData.count == 2, let latitude = CLLocationDegrees(coordinateData[0]), let longitude =  CLLocationDegrees(coordinateData[1]) else {
            return nil
        }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var iconName: String {
        
        switch category {
        case .atm: return "ic48PinATM"
        case .terminal: return "ic48PinTerminal"
        default:
            return "ic48PinOffice"
        }
    }
    
    func distance(to loacation: CLLocationCoordinate2D?) -> CLLocationDistance? {
        
        guard let coordinate = coordinate, let loacation = loacation else {
            return nil
        }

        return CLLocation.distance(from: coordinate, to: loacation)
    }
    
    func distanceFormatted(to loacation: CLLocationCoordinate2D?) -> String? {
        
        guard let distance = distance(to: loacation) else {
            return nil
        }
        
        return NumberFormatter.distance.string(fromMeters: distance)
    }
}
