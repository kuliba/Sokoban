//
//  StatefulLoaderState+isTerminated.swift
//  
//
//  Created by Igor Malyarov on 28.08.2024.
//

public extension StatefulLoaderState {
    
    var isTerminated: Bool? {
        
        switch self {
        case .failed:     return false
        case .loaded:     return true
        case .loading:    return nil
        case .notStarted: return nil
        }
    }
}
