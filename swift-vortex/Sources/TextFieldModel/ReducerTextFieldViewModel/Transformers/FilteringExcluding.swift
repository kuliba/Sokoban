//
//  FilteringExcluding.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

import Foundation
import TextFieldDomain

/// A transformer that filters text of the text state.
public struct FilteringExcluding: Transformer {
    
    @usableFromInline
    let characterSet: CharacterSet
    
    @inlinable
    public init(characterSet: CharacterSet) {
        
        self.characterSet = characterSet
    }
    
    @inlinable
    init(excludingCharacters: Set<Character>) {
        
        let string: String = excludingCharacters.map(String.init).joined()
        self.characterSet = CharacterSet(charactersIn: string)
    }
    
    @inlinable
    public func transform(_ state: TextState) -> TextState {
        
        guard !characterSet.isEmpty else { return state }
        
        let filteredUnicodeScalars = state.text.unicodeScalars
            .filter {
                !characterSet.contains($0)
            }
        let filteredText = String(filteredUnicodeScalars)
        
        if filteredText == state.text {
            return state
        } else {
            return .init(filteredText)
        }
    }
}

public extension Transformers {
    
    typealias FilteringExcluding = TextFieldModel.FilteringExcluding  // NB: Convenience type alias for discovery
}
