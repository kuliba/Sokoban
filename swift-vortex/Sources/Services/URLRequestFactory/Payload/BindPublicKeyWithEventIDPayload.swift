//
//  BindPublicKeyWithEventIDPayload.swift
//  
//
//  Created by Igor Malyarov on 12.10.2023.
//

import Foundation

extension URLRequestFactory.Service {
    
    public struct BindPublicKeyWithEventIDPayload {
        
        public let eventID: EventID
        public let key: Key
        
        public init(eventID: EventID, key: Key) {
         
            self.eventID = eventID
            self.key = key
        }
        
        func json() throws -> Data {
            
            guard !eventID.value.isEmpty
            else {
                throw Error.bindPublicKeyWithEventIDEmptyEventID
            }
            
            guard !key.value.isEmpty
            else {
                throw Error.bindPublicKeyWithEventIDEmptyKey
            }
            
            return try JSONSerialization.data(withJSONObject: [
                "eventId": eventID.value,
                "data": key.value.base64EncodedString()
            ] as [String: Any])
        }
        
        public struct EventID {
            
            public let value: String
            
            public init(value: String) {
             
                self.value = value
            }
        }
        
        public struct Key {
            
            public let value: Data
            
            public init(value: Data) {
             
                self.value = value
            }
        }
    }
}
