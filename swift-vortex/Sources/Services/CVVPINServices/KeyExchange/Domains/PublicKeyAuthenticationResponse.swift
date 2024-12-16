//
//  PublicKeyAuthenticationResponse.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

import Foundation

public struct PublicKeyAuthenticationResponse: Equatable {
    
    public let publicServerSessionKey: PublicServerSessionKey
    public let sessionID: SessionID
    public let sessionTTL: SessionTTL
    
    public init(
        publicServerSessionKey: PublicServerSessionKey,
        sessionID: SessionID,
        sessionTTL: SessionTTL
    ) {
        self.publicServerSessionKey = publicServerSessionKey
        self.sessionID = sessionID
        self.sessionTTL = sessionTTL
    }
    
    public struct PublicServerSessionKey: Equatable {
        
        public let value: String
        
        public init(value: String) {
            
            self.value = value
        }
    }
    
    public struct SessionID: Equatable {
        
        public let value: String
        
        public init(value: String) {
            
            self.value = value
        }
    }
    
    public typealias SessionTTL = TimeInterval
}
