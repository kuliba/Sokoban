//
//  TransformingReducer+transformer.swift
//
//
//  Created by Igor Malyarov on 19.05.2023.
//

public extension TransformingReducer {
    
    /// Create Text State `Reducer` with transformation.
    ///
    /// Validation, Masking, Length limitation in its simplest form
    /// could be considered as a closure that transforms one String
    /// into another String.
    /// - Parameter placeholderText: Text to set for state case `placeholder`
    /// - Parameter transform: String transformation that encapsulates validation, masking and length limitation. Default is no transformation.
    init(
        placeholderText: String,
        transformer: Transformer = Transform.identity
    ) {
        self.placeholderText = placeholderText
        self.transform = transformer.transform(_:)
    }
}
