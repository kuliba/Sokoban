//
//  HTTPClientSpy.swift
//  VortexTests
//
//  Created by Igor Malyarov on 01.08.2023.
//

@testable import Vortex
import Foundation

final class HTTPClientSpy: HTTPClient {
    
    typealias Message = (request: Request, completion: Completion)
    
    private var messages = [Message]()
    var callCount: Int { messages.count }
    
    var requests: [Request] { messages.map(\.request) }
    
    func performRequest(
        _ request: Request,
        completion: @escaping Completion
    ) {
        messages.append((request, completion))
    }
    
    func complete(
        with result: HTTPClient.Result,
        at index: Int = 0
    ) {
        messages[index].completion(result)
    }
}

extension HTTPClientSpy {
    
    func complete(
        with error: Error,
        at index: Int = 0
    ) {
        complete(with: .failure(error), at: index)
    }
    
    func complete(
        with success: (data: Data, response: HTTPURLResponse),
        at index: Int = 0
    ) {
        complete(with: .success((success.data, success.response)), at: index)
    }
    
    func complete(
        with data: Data,
        at index: Int = 0
    ) {
        complete(with: .success((data, okResponse)), at: index)
    }
}

private let okResponse = anyHTTPURLResponse(with: 200)

extension HTTPClientSpy {
    
    /// Completes the first occurrence of the specified request with the given result.
    ///
    /// - Parameters:
    ///   - result: The result to complete with.
    ///   - request: The `URLRequest` to match.
    /// - Throws: `SpyError.noMatchingRequest` if the request is not found.
    func complete(
        with result: HTTPClient.Result,
        for request: Request
    ) throws {
        
        guard let indices = requestIndexMap[request],
              let index = indices.first
        else { throw SpyError() }
        
        complete(with: result, at: index)
    }
    
    /// Completes the first occurrence of the specified request with an error.
    ///
    /// - Parameters:
    ///   - error: The error to complete with.
    ///   - request: The `URLRequest` to match.
    /// - Throws: `SpyError.noMatchingRequest` if the request is not found.
    func complete(
        with error: Error,
        for request: Request
    ) throws {
        
        try complete(with: .failure(error), for: request)
    }
    
    /// Completes the first occurrence of the specified request with the provided data and an optional response.
    ///
    /// - Parameters:
    ///   - data: The data to complete with.
    ///   - response: The `HTTPURLResponse` to complete with. Defaults to a 200 OK response if not provided.
    ///   - request: The `URLRequest` to match.
    /// - Throws: `SpyError.noMatchingRequest` if the request is not found.
    func complete(
        with data: Data,
        response: HTTPURLResponse = anyHTTPURLResponse(with: 200),
        for request: Request
    ) throws {
        
        try complete(with: .success((data, response)), for: request)
    }
    
    /// An enumeration of possible spy errors.
    struct SpyError: Error, LocalizedError {
        
        var errorDescription: String? {
            
            return "No matching request was found in the spy."
        }
    }
}

private extension HTTPClientSpy {
    
    /// Map each URLRequest to an array of indices where they appear in the messages array.
    var requestIndexMap: [Request: [Int]] {
        
        return messages.enumerated().reduce(into: [:]) { acc, element in
            
            let (index, message) = element
            acc[message.request, default: []].append(index)
        }
    }
}
