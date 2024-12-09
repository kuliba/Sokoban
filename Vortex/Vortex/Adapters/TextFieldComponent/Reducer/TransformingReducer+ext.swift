//
//  TransformingReducer+ext.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.05.2023.
//

import TextFieldComponent

extension TransformingReducer {
    
    init(placeholderText: String, limit: Int?) {
        
        if let limit = limit {
            
            self.init(
                placeholderText: placeholderText,
                transform: Transformers.limiting(limit).transform(_:)
            )
            
        } else {
            
            self.init(placeholderText: placeholderText)
            
        }
    }
}
