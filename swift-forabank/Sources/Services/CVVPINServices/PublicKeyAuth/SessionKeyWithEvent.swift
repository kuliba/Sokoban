//
//  SessionKeyWithEvent.swift
//  
//
//  Created by Igor Malyarov on 03.10.2023.
//

import Foundation

public struct SessionKeyWithEvent {
    
    let sessionKey: SessionKey
    let eventID: EventID
    let sessionTTL: SessionTTL
    
    public init(
        sessionKey: SessionKey,
        eventID: EventID,
        sessionTTL: SessionTTL
    ) {
        self.sessionKey = sessionKey
        self.eventID = eventID
        self.sessionTTL = sessionTTL
    }
    
    public struct SessionKey {
        
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
    
    public struct SessionTTL {
        
        let value: TimeInterval
        
        public init(value: TimeInterval) {
            
            self.value = value
        }
    }
}
