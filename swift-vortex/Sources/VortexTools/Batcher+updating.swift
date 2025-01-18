//
//  Batcher+updating.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

public extension Batcher {
    
    /// A typealias representing an asynchronous loading operation.
    ///
    /// - Parameters:
    ///   - Payload: The input parameter to load data for.
    ///   - Response: The result of the loading operation, delivered via a completion handler.
    typealias Load<Payload, Response> = (Payload, @escaping (Response) -> Void) -> Void
    
    /// Creates a `Batcher` that handles loading data and updating state for each parameter.
    ///
    /// This method wraps the loading operation with state updates, notifying when loading starts (`.loading`),
    /// completes successfully (`.completed`), or fails (`.failed`). If the load result is `nil` or an empty array,
    /// the parameter is treated as a failure.
    ///
    /// Items are processed **sequentially**: the next item begins loading only after the previous item has finished.
    ///
    /// - Parameters:
    ///   - load: A closure that performs an asynchronous loading operation for a given parameter.
    ///   - update: A closure that updates the state (`LoadState`) of the given parameter during the loading process.
    ///
    /// - Returns: A `Batcher` instance configured to load data and update state accordingly.
    static func updating<T>(
        load: @escaping Load<Parameter, [T]?>,
        update: @escaping (Parameter, LoadState) -> Void
    ) -> Self {
        
        self.init { payload, completion in
            
            update(payload, .loading)
            
            load(payload) {
                
                switch $0 {
                case .none: completion(LoadFailure())
                case .some: completion(nil)
                }
                
                update(payload, $0.isNilOrEmpty ? .failed : .completed)
            }
        }
    }
    
    /// An error representing a failed load operation when the result is `nil`.
    struct LoadFailure: Error {}
}
