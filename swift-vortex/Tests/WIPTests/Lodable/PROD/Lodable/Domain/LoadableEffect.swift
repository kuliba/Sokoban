//
//  LoadableEffect.swift
//  
//
//  Created by Igor Malyarov on 20.03.2025.
//

/// Represents an effect that may be delivered as a result of state changes.
public enum LoadableEffect: Equatable {
    
    /// Indicates that a load operation should be initiated.
    case load
}
