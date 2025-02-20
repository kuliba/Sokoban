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
