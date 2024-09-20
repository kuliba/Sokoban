//
//  OperationTrackerEvent.swift
//  
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// Represents the possible events that can trigger state changes within the operation tracking domain.
public enum OperationTrackerEvent: Equatable {
    
    /// Event indicating that the operation process has failed.
    case fail
    
    /// Event to reset the operation tracker to its initial state, allowing it to be reused.
    case reset
    
    /// Event to initiate the operation process.
    case start
    
    /// Event indicating that the operation process has succeeded.
    case succeed
}
