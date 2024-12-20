//
//  Transformers+ext.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import Foundation

public extension Transformers {
    
    static func countryCodeSubstitute(
        _ substitutions: [CountryCodeSubstitution]
    ) -> Transform {
        
        Transform(build: {
            
            Transformers.CountryCodeSubstitute(substitutions)
        })
    }
    
    static func filtering(
        with characterSet: CharacterSet
    ) -> Transform {
        
        Transform(build: {
            
            Transformers.Filtering(with: characterSet)
        })
    }
    
    static func filtering(
        excluding characters: [Character]
    ) -> FilteringExcluding {
        
        let characterSet = CharacterSet(
            charactersIn: characters.map(String.init).joined()
        )
        
        return Transformers.FilteringExcluding(characterSet: characterSet)
    }
    
    static func filtering(
        excluding characterSet: CharacterSet
    ) -> Transform {
        
        Transform(build: {
            
            Transformers.FilteringExcluding(characterSet: characterSet)
        })
    }
    
    static func limiting(
        _ limit: Int
    ) -> Transform {
        
        Transform(build: {
            
            Transformers.Limiting(limit)
        })
    }
    
    static func regex(
        regexPattern: String
    ) -> Transform {
        
        Transform(build: {
            
            Transformers.Regex(regexPattern: regexPattern)
        })
    }
    
    static func formatter(
        _ format: @escaping (String) -> String
    ) -> Transform {
        
        Transform { state in
            
            return .init(format(state.text))
        }
    }
    
    static func phone(
        filterSymbols: [Character],
        substitutions: [CountryCodeSubstitution],
        format: @escaping (String) -> String,
        limit: Int? = nil
    ) -> Transform {
        
        return Transform(build: {
            
            Transformers.filtering(excluding: .init(filterSymbols))
            Transformers.countryCodeSubstitute(substitutions)
            Transformers.Filtering.digits
            Transformers.formatter(format)
            if let limit { Transformers.limiting(limit) }
        })
    }
    
    static func contact(
        substitutions: [CountryCodeSubstitution],
        format: @escaping (String) -> String
    ) -> ContactTransformer {
        
        .init(substitutions: substitutions, format: format)
    }
}
