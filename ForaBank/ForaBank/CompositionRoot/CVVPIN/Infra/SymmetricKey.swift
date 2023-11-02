//
//  SymmetricKey.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

import Foundation

struct SymmetricKey {
    
    private let value: Data
    
    init(value: Data) {
        
        self.value = value
    }
}

extension SymmetricKey: RawRepresentable {
    
    typealias RawValue = Data
    
    var rawValue: Data { value }
    
    init?(rawValue: RawValue) {
        
        self.init(value: rawValue)
    }
}
