//
//  ProcessingDecorator.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

/// A decorator that adds post-processing behavior to a loading operation.
///
/// Executes a decorated task and performs additional processing on the result if successful.
/// The completion handler receives the processed response or `nil` if the operation fails.
public final class ProcessingDecorator<Payload, Response> {
    
    /// The decorated loading operation that fetches data.
    @usableFromInline
    let decoratee: Decoratee
    
    /// The processing operation that handles the successful response.
    @usableFromInline
    let processor: Processor
    
    /// Initializes the decorator with a loading operation and a processing strategy.
    ///
    /// - Parameters:
    ///   - decoratee: The primary loading function to fetch data.
    ///   - processor: The processing function to handle successful responses.
    public init(
        decoratee: @escaping Decoratee,
        processor: @escaping Processor
    ) {
        self.decoratee = decoratee
        self.processor = processor
    }
    
    /// The completion handler used by both the decoratee and processor.
    ///
    /// Passes the response if successful, or `nil` if the operation fails.
    public typealias Completion = (Response?) -> Void
    
    /// The decorated loading operation that retrieves data.
    ///
    /// - Parameters:
    ///   - payload: The input for the loading operation.
    ///   - completion: Completion handler that receives the result or `nil` on failure.
    public typealias Decoratee = (Payload, @escaping Completion) -> Void
    
    /// The processing operation that handles the successful response.
    ///
    /// - Parameters:
    ///   - response: The successful response to process.
    ///   - completion: Completion handler that delivers the processed response or `nil` if processing failed.
    public typealias Processor = (Response, @escaping Completion) -> Void
}

public extension ProcessingDecorator {
    
    /// Loads data using the decorated function and processes the result if successful.
    ///
    /// - Parameters:
    ///   - payload: The input for the loading operation.
    ///   - completion: Completion handler that receives the processed response or `nil` on failure.
    @inlinable
    func load(
        _ payload: Payload,
        completion: @escaping Completion
    ) {
        decoratee(payload) { [weak self] result in
            
            guard let self else { return }
            
            guard let result else { return completion(nil) }
            
            processor(result) { [weak self] in
                
                guard self != nil else { return }
                
                completion($0)
            }
        }
    }
}

public extension ProcessingDecorator where Payload == Void {
    
    /// Loads data without requiring a payload and processes the result if successful.
    ///
    /// This is a convenience method for cases where no input is needed for the loading operation.
    ///
    /// - Parameter completion: Completion handler that receives the processed response or `nil` if the operation fails.
    @inlinable
    func load(
        completion: @escaping Completion
    ) {
        self.load((), completion: completion)
    }
}
