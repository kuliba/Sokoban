//
//  ServerStatusCode.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation
import SwiftUI

// https://git.inn4b.ru/dbs/ios/-/wikis/Server-Status-Codes
public enum ServerStatusCode: Decodable, Equatable {
    
    case ok
    case error(Int)
    case userNotAuthorized
    case serverError
    case incorrectRequest
    case unknownRequest
    case unknownStatus(Int)
    case timeout
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        let statusCode = try container.decode(Int.self)
        switch statusCode {
        case 0: self = .ok
        case 1...45: self = .error(statusCode)
        case 101: self = .userNotAuthorized
        case 102: self = .serverError
        case 400: self = .incorrectRequest
        case 404: self = .unknownRequest
        case -1001: self = .timeout
        default:
            self = .unknownStatus(statusCode)
        }
    }
}

extension ServerStatusCode: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        switch self {
        case .ok: return "0: Ok"
        case .error(let code): return "error: \(code)"
        case .userNotAuthorized: return "101: User Not Authorized"
        case .serverError: return "102: Server Error"
        case .incorrectRequest: return "400: Incorrect Request"
        case .unknownRequest: return "404: Unknown Request"
        case .unknownStatus(let code): return "Unknown status: \(code)"
        case .timeout: return "-1001: Timeout"
        }
    }
}
