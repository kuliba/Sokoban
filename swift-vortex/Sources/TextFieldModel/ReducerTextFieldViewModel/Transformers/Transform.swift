//
//  Transform.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import TextFieldDomain

/// A transformer that invokes the given `transform` function.
///
/// ``Transform`` is useful for injecting logic into a transformer without
/// the overhead of introducing a new type that conforms to ``Transformer``.
public struct Transform: Transformer {
    
    @usableFromInline
    let transform: (TextState) -> TextState
    
    /// Initialises a transformer with a `transform` function.
    ///
    /// - Parameter transform: A function that is called when ``transform(_:inRange:with:)`` is invoked.
    @inlinable
    public init(transform: @escaping (TextState) -> TextState) {
        self.transform = transform
    }
    
    @inlinable
    public func transform(_ state: TextState) -> TextState {
        
        self.transform(state)
    }
}

public extension Transformers {
    
    typealias Transform = TextFieldModel.Transform  // NB: Convenience type alias for discovery
}
