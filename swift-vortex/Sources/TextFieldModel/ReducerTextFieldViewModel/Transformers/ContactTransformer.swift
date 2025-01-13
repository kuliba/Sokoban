//
//  ContactTransformer.swift
//  
//
//  Created by Igor Malyarov on 26.05.2023.
//

import Foundation
import TextFieldDomain

/// This transformer is used in `contacts` search text field.
///
/// Basic idea: there are two modes: one for entering contact name, another is for phone numbers - the mode set occurs when the first alphanumeric symbol is entered. If its a letter then name mode is "activated", if it's a number, then `phone` mode is on.
/// Mode essentials:
/// - `name` mode: no transformation,
/// - `phone` mode with substitutions, formatting, etc (already implemented).
///
/// - Note: for both cases entering `\n` is not allowed (should be skipped, filtered out).
public struct ContactTransformer: Transformer {
    
    @usableFromInline
    let substitutions: [CountryCodeSubstitution]
    
    @usableFromInline
    let format: (String) -> String
    
    @inlinable
    public init(
        substitutions: [CountryCodeSubstitution],
        format: @escaping (String) -> String
    ) {
        self.substitutions = substitutions
        self.format = format
    }
    
    @inlinable
    public func transform(_ state: TextState) -> TextState {
        
        let excludeNewlines = Transformers.filtering(excluding: .newlines)
        let state = excludeNewlines.transform(state)
        
        let firstNonSymbol = state.text.unicodeScalars.first {
            !Self.symbols.contains($0)
        }
        
        guard let firstNonSymbol,
              Self.digits.contains(firstNonSymbol)
        else { return state }
        
        let transformer = Transform(build: {
            
            Transformers.Filtering.digits
            Transformers.countryCodeSubstitute(substitutions)
            Transformers.formatter(format)
        })
        
        return transformer.transform(state)
    }
}

extension ContactTransformer {
    
    /// Alternative for `CharacterSet.decimalDigits` (count: 680).
    public static let digits = CharacterSet(charactersIn: "0123456789")
    
    /// The count of `symbols` is significantly smaller that count of `CharacterSet.decimalDigits.inverted` (1,111,384) and `CharacterSet.symbols` (7,770).
    public static let symbols = CharacterSet(charactersIn: "-!@#$%^&*()_+§¡™£∞§¶–≠~`,./\';][{}:|<>?≤≥÷…«“‘")
        .union(.whitespaces)
}

public extension Transformers {
    
    typealias ContactTransformer = TextFieldModel.ContactTransformer  // NB: Convenience type alias for discovery
}
