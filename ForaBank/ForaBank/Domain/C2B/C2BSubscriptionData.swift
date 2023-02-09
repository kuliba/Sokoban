//
//  C2BSubscriptionData.swift
//  ForaBank
//
//  Created by Max Gribov on 30.01.2023.
//

import Foundation

struct C2BSubscriptionData: Decodable, Equatable {
    
    let operationStatus: Status
    let title: String
    let brandIcon: String
    let brandName: String
    let redirectUrl: URL?
}

extension C2BSubscriptionData {
    
    enum Status: String, Decodable, Equatable, Unknownable {
        
        case complete = "COMPLETE"
        case rejected = "REJECTED"
        case unknown
    }
}
