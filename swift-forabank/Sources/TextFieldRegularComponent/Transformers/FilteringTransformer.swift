//
//  FilteringTransformer.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

import Foundation

public struct FilteringTransformer: Transformer {
    
    private let characterSet: CharacterSet
    
    public init(characterSet: CharacterSet) {
        
        self.characterSet = characterSet
    }
    
    public func transform(_ input: String) -> String {
        
        let filtered = input.unicodeScalars.filter { characterSet.contains($0) }
        return String(filtered)
    }
    
    public static let numbers: Self = .init(characterSet: .decimalDigits)
    public static let letters: Self = .init(characterSet: .letters)
}
