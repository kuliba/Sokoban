//
//  Transform+ext.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

public extension Transform {
    
    /// An entry point into ``TransformerBuilder`` syntax.
    ///
    /// Used to combine the outputs from multiple transformers
    /// into a single output by running each transformer in sequence.
    ///
    /// For example, the following transformer transforms a text state
    /// by filtering text allowing digits only, then limiting text length to 5,
    /// and finally matching regex pattern.
    ///
    /// ```swift
    /// let transformer = Transform(build: {
    ///
    ///     FilteringTransformer.digits
    ///     LimitingTransformer(5)
    ///     RegexTransformer(regexPattern: #"[3-5]"#)
    /// })
    /// ```
    ///
    /// - Parameter with: A transformer builder that will produce output.
    init(@TransformerBuilder build: () -> Transform) {
        
        self = build()
    }
    
    /// A ``Transform`` with no text state transformation.
    static let `identity`: Self = .init { $0 }
}
