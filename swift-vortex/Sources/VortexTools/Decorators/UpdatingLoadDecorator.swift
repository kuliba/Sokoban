//
//  UpdatingLoadDecorator.swift
//
//
//  Created by Igor Malyarov on 19.01.2025.
//

/// A decorator that updates the load state during the execution of a load operation.
///
/// This class wraps a load operation (`decoratee`) with additional functionality to track and update its state.
/// It notifies the caller of the state transitions, such as `loading`, `completed`, or `failed`.
public final class UpdatingLoadDecorator<Payload, Response> {
    
    /// A closure representing the operation to be decorated.
    /// - Parameters:
    ///   - payload: The payload to be processed.
    ///   - completion: A closure invoked with the result of the operation.
    @usableFromInline
    let decoratee: Decoratee
    
    /// A closure invoked to update the load state.
    /// - Parameters:
    ///   - payload: The payload associated with the load state.
    ///   - state: The current state of the load operation.
    @usableFromInline
    let update: Update
    
    public init(
        decoratee: @escaping Decoratee,
        update: @escaping Update
    ) {
        self.decoratee = decoratee
        self.update = update
    }
    
    public typealias Decoratee = (Payload, @escaping (Result<Response, Error>) -> Void) -> Void
    public typealias Update = (Payload, LoadState) -> Void
}

public extension UpdatingLoadDecorator {
    
    /// Executes the load operation and updates the load state.
    /// - Parameters:
    ///   - payload: The payload to be processed.
    ///   - completion: A closure invoked with the result of the operation.
    @inlinable
    func load(
        _ payload: Payload,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        update(payload, .loading)
        
        decoratee(payload) { [weak self] in
            
            guard let self else { return }
            
            completion($0)
            update(payload, $0.isFailure ? .failed : .completed)
        }
    }
}

extension Result {
    
    /// Indicates whether the result represents a failure.
    @usableFromInline
    var isFailure: Bool {
        
        switch self {
        case .failure: return true
        case .success: return false
        }
    }
}
