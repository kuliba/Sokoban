//
//  BindKeyDomain.swift
//  
//
//  Created by Igor Malyarov on 24.08.2023.
//

import Foundation

/// A namespace.
public enum BindKeyDomain<EventID> {}

public extension BindKeyDomain {
    
    typealias Payload = PublicKeyWithEventID
    typealias Result = Swift.Result<Void, ErrorWithRetryAttempts>
    typealias Completion = (Result) -> Void
    typealias BindKey = (Payload, @escaping Completion) -> Void
}

extension BindKeyDomain {
    
    public struct PublicKeyWithEventID {
        
        public let eventID: EventID
        public let data: Data
        
        public init(
            eventID: EventID,
            data: Data
        ) {
            self.eventID = eventID
            self.data = data
        }
    }
}
