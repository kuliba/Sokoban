//
//  AtmServiceData.swift
//  ForaBank
//
//  Created by Max Gribov on 04.04.2022.
//

import Foundation

struct AtmServiceData: Identifiable, Codable, Equatable {
    
    let id: Int
    let name: String
    let type: Kind
}

extension AtmServiceData {
    
    enum Kind: String, CaseIterable, Codable {
        
        case service = "SERVICE"
        case other = "OTHER"
        
        var name: String {
            
            switch self {
            case .service: return "Услуги"
            case .other: return "Другое"
            }
        }
    }
}
