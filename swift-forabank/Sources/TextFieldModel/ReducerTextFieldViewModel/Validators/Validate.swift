//
//  Validate.swift
//  
//
//  Created by Igor Malyarov on 10.05.2023.
//

import Foundation

public struct Validate: Validator {
    
    @usableFromInline
    let isValid: (String) -> Bool
    
    @inlinable
    public init(isValid: @escaping (String) -> Bool) {
        self.isValid = isValid
    }
    
    @inlinable
    public func isValid(_ input: String) -> Bool {
        
        isValid(input)
    }
}

public extension Validate {
    
    static let always: Self = .init { _ in true }
    static let never: Self = .init { _ in false }
    
    static let digits: Self = .init { input in
        input.unicodeScalars.allSatisfy {
            CharacterSet.decimalDigits.contains($0)
        }
    }
    static let letters: Self = .init { input in
        input.unicodeScalars.allSatisfy {
            CharacterSet.letters.contains($0)
        }
    }
}
