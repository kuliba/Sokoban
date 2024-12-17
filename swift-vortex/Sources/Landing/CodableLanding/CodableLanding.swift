//
//  LandingCodable.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 11.09.2023.
//

import Foundation

// без клиента, ожидается перенос кеширования

public struct CodableLanding: Codable, Equatable {

    public let header: [DataView]
    public let main: [DataView]
    public let footer: [DataView]
    public let details: [Detail]
    public let serial: String?
    
    public init(
        header: [DataView],
        main: [DataView],
        footer: [DataView],
        details: [Detail],
        serial: String?
    ) {
        self.header = header
        self.main = main
        self.footer = footer
        self.details = details
        self.serial = serial
    }
}
