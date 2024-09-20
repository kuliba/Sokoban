//
//  RemoteDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.09.2024.
//

import Foundation

/// Encapsulates types and services for handling remote network operations.
enum RemoteDomain<Payload, Response, MappingError: Error, Failure: Error> {
    
    /// Creates a `URLRequest` from the given payload.
    ///
    /// - Parameter payload: The data used to construct the request.
    /// - Throws: An error if the request cannot be created.
    /// - Returns: A configured `URLRequest`.
    typealias MakeRequest = (Payload) throws -> URLRequest
    
    /// Maps raw response data and HTTP response to a `Response` or a `MappingError`.
    ///
    /// - Parameters:
    ///   - data: The raw data received from the network.
    ///   - response: The HTTP response associated with the data.
    /// - Returns: A `Result` containing either the mapped `Response` or a `MappingError`.
    typealias MapResponse = (Data, HTTPURLResponse) -> Result<Response, MappingError>
    
    /// Performs the network request with the given payload and returns a `Response` or `Failure`.
    ///
    /// - Parameters:
    ///   - payload: The data required to perform the request.
    ///   - completion: A closure called with the result of the operation.
    typealias Service = (Payload, @escaping (Result<Response, Failure>) -> Void) -> Void
    
    /// Creates a `Service` using the provided `MakeRequest` and `MapResponse` closures.
    ///
    /// - Parameters:
    ///   - makeRequest: Closure to create a `URLRequest` from a payload.
    ///   - mapResponse: Closure to map the raw response to a `Response`.
    /// - Returns: A configured `Service`.
    typealias MakeService = (@escaping MakeRequest, @escaping MapResponse) -> Service
    
    /// Performs batch network requests with an array of payloads.
    ///
    /// - Parameters:
    ///   - payloads: An array of payloads to process.
    ///   - completion: A closure called with the array of payloads that failed during processing.
    typealias BatchService = ([Payload], @escaping ([Payload]) -> Void) -> Void
}
