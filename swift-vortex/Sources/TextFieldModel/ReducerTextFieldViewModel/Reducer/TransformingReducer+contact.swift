//
//  TransformingReducer+contact.swift
//
//
//  Created by Igor Malyarov on 26.05.2023.
//

public extension TransformingReducer {
    
    /// Create Text State `Reducer` with `contact` transformer.
    static func contact(
        placeholderText: String,
        substitutions: [CountryCodeSubstitution],
        format: @escaping (String) -> String
    ) -> Self {
        
        let transformer = Transformers.contact(
            substitutions: substitutions,
            format: format
        )
        let reducer = TransformingReducer(
            placeholderText: placeholderText,
            transformer: transformer
        )
        
        return reducer
    }
}
