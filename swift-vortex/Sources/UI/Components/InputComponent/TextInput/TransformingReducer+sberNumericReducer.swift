//
//  TransformingReducer+sberNumericReducer.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldDomain
import TextFieldModel

public extension TransformingReducer {
    
    static func sberNumericReducer(
        placeholderText: String
    ) -> Self {
        
        return .init(
            placeholderText: placeholderText,
            transformer: Transformers.sberNumeric
        )
    }
}
