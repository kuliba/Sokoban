//
//  TransformingReducer.swift
//
//
//  Created by Igor Malyarov on 14.04.2023.
//

import TextFieldDomain

public struct TransformingReducer {
    
    @usableFromInline
    let placeholderText: String
    
    @usableFromInline
    let transform: (TextState) -> TextState
    
    /// Create Text State `Reducer` with transformation.
    ///
    /// Validation, Masking, Length limitation in its simplest form
    /// could be considered as a closure that transforms one String
    /// into another String.
    /// - Parameter placeholderText: Text to set for state case `placeholder`
    /// - Parameter transform: String transformation that encapsulates validation, masking and length limitation. Default is no transformation.
    @inlinable
    public init(
        placeholderText: String,
        transform: @escaping (TextState) -> TextState
    ) {
        self.placeholderText = placeholderText
        self.transform = transform
    }
}

extension TransformingReducer: Reducer {
    
    @inlinable
    public func reduce(
        _ state: TextFieldState,
        with action: TextFieldAction
    ) throws -> TextFieldState {
        
        let changingReducer = ChangingReducer(
            placeholderText: placeholderText,
            transform: transform
        )
        let newState = try changingReducer.reduce(state, with: action)
        
        return newState
    }
}
