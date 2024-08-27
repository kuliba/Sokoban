//
//  StatefulLoaderEvent.swift
//  
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// Represents the possible events that can trigger state changes in the `StatefulLoader`.
public enum StatefulLoaderEvent: Equatable {
    
    /// Initiates the loading process.
    case load
    /// Indicates that the loading process has failed.
    case loadFailure
    /// Indicates that the loading process has succeeded.
    case loadSuccess
    /// Resets the loader to its initial state, allowing it to be reused.
    case reset
}
