//
//  AnyLoader.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

/// A type-erasing loader that wraps a closure conforming to the `Loader` protocol.
public struct AnyLoader<Payload, Response> {
    
    private let block: Block
    
    /// Initialises a new instance of `AnyLoader` with the given closure.
    ///
    /// - Parameter block: A closure that conforms to the `Loader` protocol.
    public init(
        _ block: @escaping Block
    ) {
        self.block = block
    }
    
    /// The typealias for the block that performs the loading operation.
    public typealias Block = (Payload, @escaping (Response) -> Void) -> Void
}

extension AnyLoader: Loader {
    
    /// Loads the specified payload and calls the completion handler with the response.
    ///
    /// - Parameters:
    ///   - payload: The payload to be loaded.
    ///   - completion: The completion handler to be called with the response.
    public func load(
        _ payload: Payload,
        _ completion: @escaping (Response) -> Void
    ) {
        block(payload, completion)
    }
}

extension AnyLoader where Payload == Void {
    
    /// Initialises a new instance of `AnyLoader` with a closure that does not require a payload.
    ///
    /// This initialiser is useful for cases where the loader does not need any input payload to perform its work.
    ///
    /// - Parameter block: A closure that performs the loading operation and calls the completion handler with the response.
    public init(
        _ block: @escaping (@escaping (Response) -> Void) -> Void
    ) {
        self.init { _, completion in block(completion) }
    }
}
