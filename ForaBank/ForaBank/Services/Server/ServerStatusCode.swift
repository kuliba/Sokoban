//
//  ServerStatusCode.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation
import SwiftUI

// https://git.inn4b.ru/dbs/ios/-/wikis/Server-Status-Codes
enum ServerStatusCode: Decodable, Equatable {
    
    case ok
    case error(Int)
    case userNotAuthorized
    case serverError
    case incorrectRequest
    case unknownRequest
    case unknownStatus
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        let statusCode = try container.decode(Int.self)
        switch statusCode {
        case 0: self = .ok
        case 1...45: self = .error(statusCode)
        case 101: self = .userNotAuthorized
        case 102: self = .serverError
        case 400: self = .incorrectRequest
        case 404: self = .unknownRequest
        default:
            self = .unknownStatus
        }
    }
}
