//
//  FilteringTransformer.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

import Foundation
import TextFieldDomain

/// A transformer that filters text of the text state.
public struct FilteringTransformer: Transformer {
    
    @usableFromInline
    let characterSet: CharacterSet
    
    @inlinable
    public init(with characterSet: CharacterSet) {
        
        self.characterSet = characterSet
    }
    
    @inlinable
    public func transform(_ state: TextState) -> TextState {
        
        let filtered = state.text.unicodeScalars.filter {
            characterSet.contains($0)
        }
        
        return .init(.init(filtered))
    }
}

public extension FilteringTransformer {
    
    static let digits: Self = .init(with: .decimalDigits)
    static let letters: Self = .init(with: .letters)
    
    /// Allows digits, period and comma.
    static let numeric: Self = .init(with: .decimalDigits.union(.init(charactersIn: ".,")))
}

public extension Transformers {
    
    typealias Filtering = TextFieldModel.FilteringTransformer  // NB: Convenience type alias for discovery
}
