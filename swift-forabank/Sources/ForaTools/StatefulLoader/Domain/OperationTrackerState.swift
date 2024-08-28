//
//  OperationTrackerState.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// Represents the possible states of the `OperationTracker`.
public enum OperationTrackerState: Equatable {
    
    /// The loader has failed to load the resource.
    case failed
    /// The loader is currently in the process of loading the resource.
    case loading
    /// The loader has successfully loaded the resource.
    case loaded
    /// The loader has not started the loading process.
    case notStarted
}
