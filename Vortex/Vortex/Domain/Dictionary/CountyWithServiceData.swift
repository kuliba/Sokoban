//
//  CountyWithServiceData.swift
//  Vortex
//  Created by Дмитрий Савушкин on 31.01.2023.
//

import Foundation

struct CountryWithServiceData: Codable, Equatable, Identifiable {
    
    var id: String { code }
    let code: String
    let contactCode: String?
    let name: String
    let sendCurr: String
    let md5hash: String?
    let servicesList: [Service]
    
    struct Service: Codable, Equatable {
        
        let code: Code
        let isDefault: Bool
        
        enum Code: String, Codable, Unknownable {
            
            case direct
            case directCard
            case contact
            case contactCash
            case contactAccount
            case dkm
            case dkq
            case dkr
            case pw0
            case unknown
            
            var rawValue: String {
                
                switch self {
                case .direct: return "\(Config.puref)||MIG"
                case .directCard: return "\(Config.puref)||MIG||card"
                case .contact: return "\(Config.puref)||Addressless"
                case .contactCash: return "\(Config.puref)||Addressing||cash"
                case .contactAccount: return "\(Config.puref)||Addressing||account"
                case .dkm: return "\(Config.puref)||DKM"
                case .dkq: return "\(Config.puref)||DKQ"
                case .dkr: return "\(Config.puref)||DKR"
                case .pw0: return "\(Config.puref)||PW0"
                case .unknown: return "unknown"
                }
            }
            
            init(rawValue: String) {
                
                let normalizedValue = rawValue
                       .replacingOccurrences(of: "iVortex", with: Config.puref)
                
                switch normalizedValue {
                case "\(Config.puref)||MIG": self = .direct
                case "\(Config.puref)||MIG||card": self = .directCard
                case "\(Config.puref)||Addressless": self = .contact
                case "\(Config.puref)||Addressing||cash": self = .contactCash
                case "\(Config.puref)||Addressing||account": self = .contactAccount
                case "\(Config.puref)||DKM": self = .dkm
                case "\(Config.puref)||DKQ": self = .dkq
                case "\(Config.puref)||DKR": self = .dkr
                case "\(Config.puref)||PW0": self = .pw0
                default: self = .unknown
                }
            }
        }
    }
}


