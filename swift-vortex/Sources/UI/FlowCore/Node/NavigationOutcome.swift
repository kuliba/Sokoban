//
//  NavigationOutcome.swift
//  
//
//  Created by Igor Malyarov on 08.01.2025.
//

/// Represents an outcome of processing a child's navigation state.
/// - `dismiss`: Indicates the child flow should be dismissed.
/// - `select(Select)`: Indicates the child has triggered a selection, passing any relevant data.
public enum NavigationOutcome<Select> {
    
    case dismiss
    case select(Select)
}

extension NavigationOutcome: Equatable where Select: Equatable {}
