//
//  OperationTrackerState.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// Represents the possible states within the operation tracking domain.
public enum OperationTrackerState: Equatable {
    
    /// The operation has failed to complete successfully.
    case failure
    
    /// The operation is currently in progress.
    case inflight
    
    /// The operation has not started yet.
    case notStarted
    
    /// The operation has completed successfully.
    case success
}
