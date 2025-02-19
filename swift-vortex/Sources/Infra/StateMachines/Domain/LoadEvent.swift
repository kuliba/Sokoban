//
//  LoadEvent.swift
//
//
//  Created by Igor Malyarov on 19.02.2025.
//

/// Represents the events that can trigger state transitions during loading.
public enum LoadEvent<Success, Failure: Error> {
    
    /// Initiates the loading process.
    case load
    /// Delivers the result of the loading process.
    case loaded(Result<Success, Failure>)
}

extension LoadEvent: Equatable where Success: Equatable, Failure: Equatable {}
