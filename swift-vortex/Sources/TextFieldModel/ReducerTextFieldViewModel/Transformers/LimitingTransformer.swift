//
//  LimitingTransformer.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import TextFieldDomain

/// A transformer that limits the text lengths.
public struct LimitingTransformer: Transformer {
    
    @usableFromInline
    let limit: Int
    
    @inlinable
    public init(_ limit: Int) {
        self.limit = limit
    }
    
    @inlinable
    public func transform(_ state: TextState) -> TextState {
        
        .init(
            .init(state.text.prefix(limit)),
            cursorPosition: min(state.cursorPosition, limit)
        )
    }
}

public extension Transformers {
    
    typealias Limiting = TextFieldModel.LimitingTransformer  // NB: Convenience type alias for discovery
}
