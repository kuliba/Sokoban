//
//  PublicServerSessionKeyPayload.swift
//  
//
//  Created by Igor Malyarov on 18.07.2023.
//

import Foundation

public struct PublicServerSessionKeyPayload {
    
    let publicServerSessionKey: PublicServerSessionKey
    let eventID: EventID
    let sessionTTL: TimeInterval
    
    public init(
        publicServerSessionKey: PublicServerSessionKey,
        eventID: EventID,
        sessionTTL: TimeInterval
    ) {
        self.publicServerSessionKey = publicServerSessionKey
        self.eventID = eventID
        self.sessionTTL = sessionTTL
    }
    
    public struct PublicServerSessionKey {
        
        let value: String
        
        public init(value: String) {
            
            self.value = value
        }
    }
    
    public struct EventID {
        
        let value: String
        
        public init(value: String) {
            
            self.value = value
        }
    }
}
