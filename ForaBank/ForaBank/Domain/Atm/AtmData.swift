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
    let cityId: Int
    let address: String
    let schedule: String
    let location: LocationData
    let email: String
    let phoneNumber: String
    let action: Action
    
    var servicesListSet: Set<Int> { Set(serviceIdList) }

    internal init(id: String, name: String, type: Int, serviceIdList: [Int], metroStationList: [Int], cityId: Int, address: String, schedule: String, location: LocationData, email: String, phoneNumber: String, action: AtmData.Action) {
        self.id = id
        self.name = name
        self.type = type
        self.serviceIdList = serviceIdList
        self.metroStationList = metroStationList
        self.cityId = cityId
        self.address = address
        self.schedule = schedule
        self.location = location
        self.email = email
        self.phoneNumber = phoneNumber
        self.action = action
    }
    
    enum CodingKeys : String, CodingKey, Decodable {
        
        case id = "xmlId"
        case name, type, serviceIdList, metroStationList, cityId, address, schedule, location, email, phoneNumber, action
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(Int.self, forKey: .type)
        self.serviceIdList = try container.decode([Int].self, forKey: .serviceIdList)
        self.metroStationList = try container.decode([Int].self, forKey: .metroStationList)
        self.cityId = try container.decode(Int.self, forKey: .cityId)
        self.address = try container.decode(String.self, forKey: .address)
        self.schedule = try container.decode(String.self, forKey: .schedule)
        let locationString = try container.decode(String.self, forKey: .location)
        self.location = try LocationData(with: locationString)
        self.email = try container.decode(String.self, forKey: .email)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.action = try container.decode(Action.self, forKey: .action)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(serviceIdList, forKey: .serviceIdList)
        try container.encode(metroStationList, forKey: .metroStationList)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(address, forKey: .address)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(location.stringValue, forKey: .location)
        try container.encode(email, forKey: .email)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(action, forKey: .action)
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
    
    var coordinate: CLLocationCoordinate2D { location.coordinate }
    
    var iconName: String {
        
        switch category {
        case .atm: return "ic48PinATM"
        case .terminal: return "ic48PinTerminal"
        default:
            return "ic48PinOffice"
        }
    }
    
    func distance(to loacation: CLLocationCoordinate2D?) -> CLLocationDistance? {
        
        guard let loacation = loacation else {
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
