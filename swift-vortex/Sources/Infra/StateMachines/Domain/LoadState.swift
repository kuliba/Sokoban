//
//  LoadState.swift
//
//
//  Created by Igor Malyarov on 19.02.2025.
//

/// Represents the various states of a loading process.
public enum LoadState<Success, Failure> {
    
    /// Loading completed successfully with a value.
    case completed(Success)
    
    /// Loading failed with an error.
    case failure(Failure)
    
    /// Loading is in progress. May contain a previously loaded value.
    case loading(Success?)
    
    /// No loading process has been started.
    case pending
}

extension LoadState: Equatable where Success: Equatable, Failure: Equatable {}

public extension LoadState {
    
    /// Returns the `true` if the state is `.loading`, otherwise `false`.
    var isLoading: Bool {
        
        guard case .loading = self else { return false }
        return true
    }
    
    /// Returns the failure value if the state is `.failure`, otherwise `nil`.
    var failure: Failure? {
        
        guard case let .failure(failure) = self else { return nil }
        return failure
    }
    
    /// Returns the success value if the state is `.completed`, otherwise `nil`.
    var success: Success? {
        
        guard case let .completed(success) = self else { return nil }
        return success
    }
}
