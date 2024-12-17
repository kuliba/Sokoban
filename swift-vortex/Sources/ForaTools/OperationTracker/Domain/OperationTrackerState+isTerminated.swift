//
//  OperationTrackerState+isTerminated.swift
//  
//
//  Created by Igor Malyarov on 28.08.2024.
//

public extension OperationTrackerState {
    
    var isTerminated: Bool? {
        
        switch self {
        case .failure:     return false
        case .success:     return true
        case .inflight:    return nil
        case .notStarted: return nil
        }
    }
}
