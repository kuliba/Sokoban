//
//  SymmetricCryptoPayload.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

import Foundation

public struct SymmetricCryptoPayload: Equatable {
    
    let publicServerSessionKey: String
    let eventID: String
    let sessionTTL: TimeInterval
    
    public init(
        publicServerSessionKey: String,
        eventID: String,
        sessionTTL: TimeInterval
    ) {
        self.publicServerSessionKey = publicServerSessionKey
        self.eventID = eventID
        self.sessionTTL = sessionTTL
    }
}
