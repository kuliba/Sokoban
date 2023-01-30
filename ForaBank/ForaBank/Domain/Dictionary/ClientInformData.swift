//
//  ClientInformData.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 30.01.2023.
//

import Foundation

struct ClientInformData: Codable, Equatable {
        
    let authorized: [String]
    let notAuthorized: String?
    let serial: String
}
