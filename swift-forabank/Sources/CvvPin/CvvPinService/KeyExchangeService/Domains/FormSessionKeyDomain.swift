//
//  FormSessionKeyDomain.swift
//  
//
//  Created by Igor Malyarov on 19.08.2023.
//

import Foundation

/// A namespace.
public enum FormSessionKeyDomain {}

public extension FormSessionKeyDomain {
    
    typealias Request = SecretRequest
    typealias Response = PublicServerSessionKeyPayload
    typealias Result = Swift.Result<Response, Error>
    typealias Completion = (Result) -> Void
    typealias FormSessionKey = (Request, @escaping Completion) -> Void
}

extension FormSessionKeyDomain {
    
    public struct SecretRequest: Equatable {
        
        public let code: String
        public let data: Data
        
        public init(code: String, data: Data) {
            
            self.code = code
            self.data = data
        }
    }
    
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
}
