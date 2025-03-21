//
//  LoadableEvent.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

/// Defines events that can modify the loadable state.
public enum LoadableEvent<Resource, Failure: Error> {
    
    /// Initiates a new load operation.
    case load
    
    /// Represents the completion of a load operation with success or failure.
    case loaded(Result<Resource, Failure>)
}

extension LoadableEvent: Equatable where Resource: Equatable, Failure: Equatable {}
