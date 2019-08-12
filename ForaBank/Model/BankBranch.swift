//
//  BankBranch.swift
//  TestHero
//
//  Created by Sergey on 20/12/2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

import Foundation

struct BankBranches: Decodable {
    var branches: [BankBranch]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        branches = [BankBranch]()
        while !container.isAtEnd {
            let branch = try! container.decode(BankBranch.self)
            branches.append(branch)
        }
    }
}

struct BankBranch: Decodable {
    let code: String?
    let type: String?
    let name: String?
    let city: String?
    let activity: String?
    let address: String?
    let currency: String?
    let schedule: String?
    let metro: String?
    let latitude: Double?
    let longitude: Double?
    let changeAt: Date?
    let phone: String?
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case code
        case type
        case name
        case city
        case activity
        case address
        case currency
        case schedule
        case metro
        case latitude
        case longitude
        case changeAt = "change_at"
        case phone
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code = decodeToString(fromContainer: container, key: .code)
        self.type = decodeToString(fromContainer: container, key: .type)
        self.name = decodeToString(fromContainer: container, key: .name)
        self.city = decodeToString(fromContainer: container, key: .city)
        self.activity = decodeToString(fromContainer: container, key: .activity)
        self.address = decodeToString(fromContainer: container, key: .address)
        self.currency = decodeToString(fromContainer: container, key: .currency)
        self.schedule = decodeToString(fromContainer: container, key: .schedule)
        self.metro = decodeToString(fromContainer: container, key: .metro)
        self.latitude = decodeToDouble(fromContainer: container, key: .latitude)
        self.longitude = decodeToDouble(fromContainer: container, key: .longitude)
        if let date = try? container.decodeIfPresent(Date.self, forKey: .changeAt) {
            self.changeAt = date
        } else {
            self.changeAt = nil
        }
        self.phone = decodeToString(fromContainer: container, key: .phone)
        self.id = decodeToInt(fromContainer: container, key: .id)
    }
}
