//
//  Reducers+ext.swift
//  
//
//  Created by Igor Malyarov on 26.05.2023.
//

import Foundation
import TextFieldDomain

public extension Reducers {
    
    static func changing(
        placeholderText: String,
        change: @escaping (TextState, String, NSRange) throws -> TextState
    ) -> ChangingReducer {
        
        .init(
            placeholderText: placeholderText,
            change: change
        )
    }
    
    static func digitFiltering(
        placeholderText: String
    ) -> ChangingReducer {
        
        .init(
            placeholderText: placeholderText
        ) { textState, replacementText, range in
            
            let filtered = replacementText.filter(\.isNumber)
            
            return try textState.replace(inRange: range, with: filtered)
            
        }
    }
}
