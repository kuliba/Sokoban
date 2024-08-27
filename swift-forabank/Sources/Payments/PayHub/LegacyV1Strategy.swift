//
//  LegacyV1Strategy.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// A strategy class that processes a payload using either a legacy method or a V1 method
/// depending on a provided boolean flag. Supports custom error handling through the generic `Failure` type.
public final class LegacyV1Strategy<Payload, Legacy, V1, Failure: Error> {
    
    /// Closure that processes a Payload to produce a Legacy result.
    private let makeLegacy: MakeLegacy
    
    /// Closure that processes a Payload to produce a V1 result asynchronously.
    /// The result is wrapped in a `Result` type, which can contain a success (`V1`) or failure (`Failure`) value.
    private let makeV1: MakeV1
    
    /// Initialises the strategy with the provided legacy and V1 processing closures.
    ///
    /// - Parameters:
    ///   - makeLegacy: A closure that processes the payload to produce a legacy result.
    ///   - makeV1: A closure that processes the payload to produce a V1 result asynchronously.
    public init(
        makeLegacy: @escaping MakeLegacy,
        makeV1: @escaping MakeV1
    ) {
        self.makeLegacy = makeLegacy
        self.makeV1 = makeV1
    }
    
    /// Typealias for a closure that converts a Payload into a Legacy result.
    public typealias MakeLegacy = (Payload) -> Legacy
    
    /// Typealias for a closure that converts a Payload into a V1 result asynchronously.
    /// The closure takes a payload and a completion handler as parameters.
    /// The completion handler returns a `Result` that can either contain a V1 result or a `Failure` error.
    public typealias MakeV1 = (Payload, @escaping (Result<V1, Failure>) -> Void) -> Void
}

public extension LegacyV1Strategy {
    
    /// An enum representing the possible responses of the strategy when processing a payload.
    ///
    /// - legacy: Indicates that the processing was done using the legacy method,
    ///           and contains the resulting Legacy value.
    /// - v1: Indicates that the processing was done using the V1 method,
    ///       and contains the resulting V1 value wrapped in a `Result` to account for success or failure.
    enum Response {
        case legacy(Legacy)
        case v1(Result<V1, Failure>)
    }
    
    /// Typealias for the completion handler that is called with the strategy's response.
    typealias Completion = (Response) -> Void
    
    /// Composes the response based on whether the legacy flag is true or false.
    ///
    /// - Parameters:
    ///   - isLegacy: A boolean flag indicating whether to use the legacy method.
    ///   - payload: The payload to be processed.
    ///   - completion: The completion handler that will be called with the response.
    func compose(
        isLegacy: Bool,
        payload: Payload,
        _ completion: @escaping Completion
    ) {
        if isLegacy {
            completion(.legacy(makeLegacy(payload)))
        } else {
            makeV1(payload) { completion(.v1($0)) }
        }
    }
}
