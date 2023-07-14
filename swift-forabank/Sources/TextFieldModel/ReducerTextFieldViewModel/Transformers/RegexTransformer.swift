//
//  RegexTransformer.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import Foundation
import TextFieldDomain

/// A transformer that applies regex pattern to the text of the text state.
public struct RegexTransformer: Transformer {
    
    // TODO: Use new Apple's Regex API
    @usableFromInline
    let regexPattern: String
    
    @inlinable
    public init(regexPattern: String) {
        self.regexPattern = regexPattern
    }
    
    @inlinable
    public func transform(_ state: TextState) -> TextState {
        
        guard let regex = try? NSRegularExpression(pattern: regexPattern)
        else { return .init("") }
        
        let results = regex.matches(in: state.text, range: .init(location: 0, length: state.text.count))
        let matches = results.compactMap { (result) -> Substring? in
            
            guard let range = Range(result.range, in: state.text)
            else { return nil }
            
            return state.text[range]
        }
        
        let text = String(matches.joined())
        
        return .init(text)
    }
}

public extension Transformers {
    
    typealias Regex = TextFieldModel.RegexTransformer  // NB: Convenience type alias for discovery
}
