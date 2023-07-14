//
//  Transformer.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import TextFieldDomain

/// A protocol that describes how to transform the ``TextState``.
///
/// Conform types to this protocol to perform custom logic of text state transformations.
public protocol Transformer {
    
    /// Transforms the text state.
    func transform(_ state: TextState) -> TextState
}
