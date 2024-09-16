//
//  RemoteNanoServiceFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.09.2024.
//

import Foundation
import RemoteServices

/// A protocol for creating remote nano services.
protocol RemoteNanoServiceFactory {
    
    /// A closure that creates a `URLRequest` from a payload.
    typealias MakeRequest<Payload> = (Payload) throws -> URLRequest
    
    /// The error type used during response mapping.
    typealias MapError = RemoteServices.ResponseMapper.MappingError
    
    /// A closure that maps response data to a result.
    typealias Map<Response> = (Data, HTTPURLResponse) -> Result<Response, MapError>
    
    /// A service that processes a payload and returns a response or error.
    typealias Service<Payload, Response> = (Payload, @escaping (Result<Response, Error>) -> Void) -> Void
    
    /// Composes a service using request creation and response mapping.
    func compose<Payload, Response>(
        makeRequest: @escaping MakeRequest<Payload>,
        mapResponse: @escaping Map<Response>
    ) -> Service<Payload, Response>
}
