//
//  LoadableState.swift
//
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import Foundation

public enum Loadable<State> {
    
    /// `nil` represents clean state, `some` - previously loaded.
    case loading(State?)
    
    /// `nil` represents idle state, `some` - loaded result.
    case loaded(Loaded?)
    
    public typealias Loaded = Result<State, LoadFailure>
}

public extension Loadable {
    
    var isLoading: Bool {
        
        guard case .loading = self else { return false }
        
        return true
    }
    
    var state: State? {
        
        get {
            
            guard case let .loaded(.success(state)) = self
            else { return nil }
            
            return state
        }
        
        set(newValue) {
            
            guard let newValue, case .loaded(.success) = self
            else { return }
            
            self = .loaded(.success(newValue))
        }
    }
}
