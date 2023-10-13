//
//  SessionIDWithDataPayload.swift
//  
//
//  Created by Igor Malyarov on 12.10.2023.
//

import Foundation

extension URLRequestFactory.Service {
    
    public struct SessionIDWithDataPayload {
        
        public let sessionID: SessionID
        public let data: Data
        
        public init(
            sessionID: SessionID,
            data: Data
        ) {
            self.sessionID = sessionID
            self.data = data
        }
        
        func json() throws -> Data {
            
            guard !sessionID.value.isEmpty
            else {
                throw Error.emptySessionID
            }
            
            guard !data.isEmpty
            else {
                throw Error.emptyData
            }
            
            return try JSONSerialization.data(withJSONObject: [
                "sessionId": sessionID.value,
                "data": data.base64EncodedString()
            ] as [String: String])
        }
        
        public struct SessionID: Equatable {
            
            public let value: String
            
            public init(value: String) {
             
                self.value = value
            }
        }
    }
}
