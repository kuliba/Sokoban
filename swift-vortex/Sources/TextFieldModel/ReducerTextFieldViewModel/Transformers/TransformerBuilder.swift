//
//  TransformerBuilder.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

/// A custom parameter attribute that constructs transformers from closures.
/// The constructed transformer runs a number of transformers, one after the other,
/// and accumulates their outputs.
///
/// The ``Transform`` transformer acts as an entry point into `@TransformerBuilder`
/// syntax, where you can list all of the transformers you want to run.
/// For example, to transform text state by filtering text allowing only letters
/// and limiting text length to 5:
///
/// ```swift
/// let transformer = Transform(build: {
///
///   FilteringTransformer.letters
///   LimitingTransformer(5)
/// })
/// ```
@resultBuilder
public enum TransformerBuilder {}

public extension TransformerBuilder {
    
    static func buildBlock(_ components: Transformer...) -> Transform {
        
        Transform { state in
            
            var state = state
            
            for transformer in components {
                
                state = transformer.transform(state)
            }
            
            return state
        }
    }
    
    /// support for ‘if’ statements without an ‘else’
    static func buildOptional(_ component: Transform?) -> Transform {
        
        Transform { state in
            
            guard let component else { return state }
            
            return component.transform(state)
        }
    }
    
    /// support for ‘if’-‘else’ and ’switch’
    static func buildEither(first component: Transform) -> Transform {
        component
    }
    
    /// support for ‘if’-‘else’ and ’switch’
    static func buildEither(second component: Transform) -> Transform {
        component
    }
}
