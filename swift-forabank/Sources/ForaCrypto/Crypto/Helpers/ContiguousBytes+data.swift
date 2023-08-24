//
//  ContiguousBytes+data.swift
//  
//
//  Created by Igor Malyarov on 18.08.2023.
//

import Foundation

public extension ContiguousBytes {
    
    var data: Data {
        
        var result = Data()
        self.withUnsafeBytes {
            result = Data($0)
        }
        return result
    }
}
