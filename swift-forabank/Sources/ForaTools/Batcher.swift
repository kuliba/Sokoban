//
//  Batcher.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

/// A class that processes a batch of parameters sequentially, performing a given action on each
/// and accumulating the parameters that result in a failure.
public final class Batcher<Parameter> {
    
    /// The closure that will be called for each parameter in the batch.
    private let perform: Perform
    
    /// Initialises a new instance of `Batcher`.
    ///
    /// - Parameter perform: The closure that performs an action on each parameter.
    public init(perform: @escaping Perform) {
        
        self.perform = perform
    }
    
    /// A closure that is called upon completion of processing a parameter.
    ///
    /// - Parameter error: An optional error if the processing failed.
    public typealias PerformCompletion = (Error?) -> Void
    
    /// A closure that performs an action on a given parameter.
    ///
    /// - Parameters:
    ///   - parameter: The input parameter to be processed.
    ///   - completion: A closure to call when processing is complete.
    public typealias Perform = (Parameter, @escaping PerformCompletion) -> Void
}

public extension Batcher {
    
    /// Initiates the sequential processing of the provided parameters.
    ///
    /// - Parameters:
    ///   - parameters: An array of parameters to be processed.
    ///   - completion: A completion handler that is called with the array of parameters that failed during processing.
    func process(
        _ parameters: [Parameter],
        completion: @escaping ([Parameter]) -> Void
    ) {
        process(parameters: .init(parameters), failedParameters: [], completion: completion)
    }
    
    /// Initiates the sequential processing of the provided parameters by calling the instance as a function.
    /// This method ensures that `self` is retained throughout the processing.
    ///
    /// - Parameters:
    ///   - parameters: An array of parameters to be processed.
    ///   - completion: A completion handler that is called with the array of parameters that failed during processing.
    func callAsFunction(
        _ parameters: [Parameter],
        completion: @escaping ([Parameter]) -> Void
    ) {
        process(parameters) { [self] in
            
            completion($0)
            _ = self
        }
    }
}

private extension Batcher {
    
    /// Recursively processes the parameters, keeping track of those that fail.
    ///
    /// - Parameters:
    ///   - parameters: A slice of the remaining parameters to be processed.
    ///   - failedParameters: A slice of parameters that have failed during processing.
    ///   - completion: A completion handler that is called with the array of parameters that failed during processing.
    func process(
        parameters: ArraySlice<Parameter>,
        failedParameters: ArraySlice<Parameter>,
        completion: @escaping ([Parameter]) -> Void
    ) {
        // Base case: if no parameters are left, return the accumulated failed parameters.
        guard let parameter = parameters.first else {
            
            return completion(.init(failedParameters))
        }
        
        // Mutable copy of the failed parameters slice.
        var failedParameters = failedParameters
        
        // Perform the action on the current parameter.
        perform(parameter) { [weak self] error in
            
            // If an error occurred, add the current parameter to the failed parameters list.
            if error != nil {
                
                failedParameters.append(parameter)
            }
            
            // Recursively process the remaining parameters.
            self?.process(
                parameters: parameters.dropFirst(),
                failedParameters: failedParameters,
                completion: completion
            )
        }
    }
}
