//
//  GetUINDataPayload.swift
//  
//
//  Created by Igor Malyarov on 16.02.2025.
//

import RemoteServices

extension RequestFactory {
    
    public struct GetUINDataPayload: Equatable {
        
        public let uin: String
        
        public init(uin: String) {
            
            self.uin = uin
        }
    }
}
