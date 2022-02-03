//
//  PrintFormType.swift
//  ForaBank
//
//  Created by Max Gribov on 02.02.2022.
//

import Foundation

enum PrintFormType: String, Codable {
    
    case sbp
    case direct
    case `internal`
    case external
    case mobile
    case internet
    case transport
    case taxAndStateService
}
