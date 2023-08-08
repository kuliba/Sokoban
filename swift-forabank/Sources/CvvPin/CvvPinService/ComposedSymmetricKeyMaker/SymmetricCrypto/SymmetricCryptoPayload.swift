//
//  SymmetricCryptoPayload.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

import Foundation

public struct SymmetricCryptoPayload: Equatable {
    
    public let publicServerSessionKey: String
    public let eventID: String
    public let sessionTTL: TimeInterval
    
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
