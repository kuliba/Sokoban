//
//  AtmCityData.swift
//  ForaBank
//
//  Created by Max Gribov on 12.04.2022.
//

import Foundation

struct AtmCityData: Identifiable, Codable, Equatable {

    let id: Int
    let name: String
    let region: Int
    let location: LocationData
    
    enum CodingKeys : String, CodingKey, Decodable {
        
        case id, name, region, location
    }
    
    internal init(id: Int, name: String, region: Int, location: LocationData) {
        
        self.id = id
        self.name = name
        self.region = region
        self.location = location
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.region = try container.decode(Int.self, forKey: .region)
        self.location = try container.decode(LocationData.self, forKey: .location)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(region, forKey: .region)
        try container.encode(location, forKey: .location)
    }
}
