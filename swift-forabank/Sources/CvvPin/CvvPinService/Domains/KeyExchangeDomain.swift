//
//  KeyExchangeDomain.swift
//  
//
//  Created by Igor Malyarov on 18.08.2023.
//

import Foundation

/// A namespace.
public enum KeyExchangeDomain {}

public extension KeyExchangeDomain {
    
    typealias Result = Swift.Result<KeyExchange, Error>
    typealias Completion = (Result) -> Void
    typealias ExchangeKey = (SessionCode, @escaping Completion) -> Void
    typealias MakeSecretRequest = (SessionCode) throws -> SecretRequest
}
 
extension KeyExchangeDomain {
    
    public struct SessionCode: Equatable {
        
        public let value: String
        
        public init(value: String) {
            
            self.value = value
        }
    }
    
    public struct KeyExchange: Equatable {
        
        public let sharedSecret: Data
        public let eventID: EventID
        public let sessionTTL: TimeInterval
        
        public init(
            sharedSecret: Data,
            eventID: EventID,
            sessionTTL: TimeInterval
        ) {
            self.sharedSecret = sharedSecret
            self.eventID = eventID
            self.sessionTTL = sessionTTL
        }
        
        public struct EventID: Equatable {
            
            public let value: String
            
            public init(value: String) {
                
                self.value = value
            }
        }
    }
    
    public struct SecretRequest: Equatable {
        
        public let code: KeyExchangeDomain.SessionCode
        public let data: Data
        
        public init(
            code: KeyExchangeDomain.SessionCode,
            data: Data
        ) {
            self.code = code
            self.data = data
        }
    }
}
