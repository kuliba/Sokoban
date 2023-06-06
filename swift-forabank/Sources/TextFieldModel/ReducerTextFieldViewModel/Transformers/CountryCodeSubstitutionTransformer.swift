//
//  CountryCodeSubstitutionTransformer.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import TextFieldDomain

/// A transformer of the text state that tries to match a country code substitution
/// and apply it if found.
public struct CountryCodeSubstitutionTransformer: Transformer {
    
    @usableFromInline
    let substitutions: [CountryCodeSubstitution]
    
    @inlinable
    public init(_ substitutions: [CountryCodeSubstitution]) {
        
        self.substitutions = substitutions
    }
    
    @inlinable
    public func transform(_ state: TextState) -> TextState {
        
        guard let substitution = substitutions.firstTo(matching: state.text)
        else { return state }
        
        return .init(substitution)
    }
}

public extension Transformers {
    
    typealias CountryCodeSubstitute = TextFieldModel.CountryCodeSubstitutionTransformer  // NB: Convenience type alias for discovery
}
