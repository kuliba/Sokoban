//
//  ClientInformZoneData.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 21.10.2024.
//

import Foundation

struct ClientInformZoneData: Codable, Equatable {
    
    let serial: String
    let clientInformZone: [String]
}
