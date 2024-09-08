//
//  RemoteNanoServiceFactory.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.09.2024.
//

import Foundation

/// A protocol that defines a factory for creating and handling remote network services.
protocol RemoteNanoServiceFactory {
    
    /// A closure type for creating a `URLRequest` from a given payload.
    ///
    /// - Parameter Payload: The type of the input payload used to create the `URLRequest`.
    /// - Throws: An error if the request creation fails.
    /// - Returns: A `URLRequest` representing the network request to be sent.
    typealias CreateRequest<Payload> = (Payload) throws -> URLRequest
    
    /// A closure type for mapping network response data and an `HTTPURLResponse` to a result.
    ///
    /// - Parameters:
    ///   - data: The response data from the network request.
    ///   - response: The `HTTPURLResponse` associated with the network request.
    /// - Returns: A `Result` containing either the parsed response or a failure (an `Error`).
    typealias MapResponse<Response> = (Data, HTTPURLResponse) -> Result<Response, Error>
    
    /// A type representing a network service that takes a payload and provides either a response or a failure.
    ///
    /// - Parameters:
    ///   - payload: The input payload used to create the network request.
    ///   - completion: A closure that is called with the result of the network request, which can either be a successful response or an error.
    typealias NanoService<Payload, Response> = (Payload, @escaping (Result<Response, Error>) -> Void) -> Void
    
    /// Composes a network service using closures for request creation and response mapping.
    ///
    /// - Parameters:
    ///   - createRequest: A closure that creates a `URLRequest` from the provided payload.
    ///   - mapResponse: A closure that maps the response data and HTTP response to a `Result<Response, Error>`.
    /// - Returns: A network service that processes the payload and provides a result containing either a response or a failure.
    func compose<Payload, Response>(
        createRequest: @escaping CreateRequest<Payload>,
        mapResponse: @escaping MapResponse<Response>
    ) -> NanoService<Payload, Response>
}

extension RemoteNanoServiceFactory {
    
    /// A closure type for creating a `URLRequest` without requiring a payload.
    ///
    /// - Throws: An error if the request creation fails.
    /// - Returns: A `URLRequest` representing the network request to be sent.
    typealias CreateRequestVoid = () throws -> URLRequest
    
    /// A type representing a network service that does not require a payload and provides either a response or a failure.
    ///
    /// - Parameter completion: A closure that is called with the result of the network request, which can either be a successful response or an error.
    typealias NanoServiceVoid<Response> = (@escaping (Result<Response, Error>) -> Void) -> Void
    
    /// Composes a network service that does not require a payload for request creation.
    ///
    /// - Parameters:
    ///   - createRequest: A closure that creates a `URLRequest` without requiring a payload.
    ///   - mapResponse: A closure that maps the response data and HTTP response to a `Result<Response, Error>`.
    /// - Returns: A network service that provides a result containing either a response or a failure, without requiring a payload.
    func compose<Response>(
        createRequest: @escaping CreateRequestVoid,
        mapResponse: @escaping MapResponse<Response>
    ) -> NanoServiceVoid<Response> {
        
        let composed: NanoService<Void, Response> = compose(
            createRequest: { _ in try createRequest() },
            mapResponse: mapResponse
        )
        
        return { composed((), $0) }
    }
}
