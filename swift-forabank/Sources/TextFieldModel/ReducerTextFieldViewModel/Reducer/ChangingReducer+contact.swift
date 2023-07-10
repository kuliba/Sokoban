//
//  ChangingReducer+contact.swift
//  
//
//  Created by Igor Malyarov on 10.07.2023.
//

import Foundation
import TextFieldDomain

public extension ChangingReducer {
    
    /// Create Text State `Reducer` with `contact` transformer and input cleanup.
    @inlinable
    static func contact(
        placeholderText: String,
        cleanup: @escaping (String) -> String,
        substitutions: [CountryCodeSubstitution],
        format: @escaping (String) -> String
    ) -> Self {
        
        let transformer = Transformers.contact(
            substitutions: substitutions,
            format: format
        )
        let reducer = ChangingReducer(
            placeholderText: placeholderText,
            change: { textState, replacementText, range in
                
                let replacementText = cleanup(replacementText)
                let textState = try textState.replace(
                    inRange: range,
                    with: replacementText
                )
                
                return transformer.transform(textState)
            }
        )
        
        return reducer
    }
}
