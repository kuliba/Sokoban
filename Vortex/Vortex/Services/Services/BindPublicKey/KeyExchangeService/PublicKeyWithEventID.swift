//
//  PublicKeyWithEventID.swift
//  Vortex
//
//  Created by Igor Malyarov on 05.08.2023.
//

import Foundation

struct PublicKeyWithEventID: Equatable {
    
    let key: Key
    let eventID: EventID
    
    struct Key: Equatable {
        
        private let data: Data
        
        init(keyData: Data) {
            
            self.data = keyData
        }
        
        var base64String: String { keyData.base64EncodedString() }
        var keyData: Data { data }
        var isEmpty: Bool { keyData.isEmpty }
    }
    
    struct EventID: Equatable {
        
        let value: String
        
        var isEmpty: Bool { value.isEmpty }
    }
}
