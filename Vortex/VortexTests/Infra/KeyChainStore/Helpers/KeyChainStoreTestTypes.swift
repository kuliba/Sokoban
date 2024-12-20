//
//  TestTypes.swift
//  
//
//  Created by Igor Malyarov on 14.10.2023.
//

import Foundation

struct KeyTag {
    
    let value: String
}

extension KeyTag: RawRepresentable {
    
    var rawValue: String { value }
    
    init?(rawValue: String) {
        
        self.value = rawValue
    }
}

struct Key: Equatable {
    
    let value: Data
}

extension Key: RawRepresentable {
    
    var rawValue: Data { value }
    
    init?(rawValue: Data) {
        
        self.value = rawValue
    }
}
