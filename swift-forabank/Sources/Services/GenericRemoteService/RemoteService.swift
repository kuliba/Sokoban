//
//  RemoteService.swift
//  
//
//  Created by Igor Malyarov on 01.08.2023.
//

import Foundation

/// A namespace.
public enum HTTPDomain {}

public extension HTTPDomain {
    
    typealias Request = URLRequest
    typealias Response = (Data, HTTPURLResponse)
    typealias Result = Swift.Result<Response, Error>
    typealias Completion = (Result) -> Void
}

public final class RemoteService<Input, Output> {
    
    public typealias MakeRequest = (Input) throws -> HTTPDomain.Request
    public typealias PerformRequest = (HTTPDomain.Request, @escaping HTTPDomain.Completion) -> Void
    public typealias MapResponse = (Data, HTTPURLResponse) throws -> Output
    
    private let makeRequest: MakeRequest
    private let performRequest: PerformRequest
    private let mapResponse: MapResponse
    
    public init(
        makeRequest: @escaping MakeRequest,
        performRequest: @escaping PerformRequest,
        mapResponse: @escaping MapResponse
    ) {
        self.makeRequest = makeRequest
        self.performRequest = performRequest
        self.mapResponse = mapResponse
    }
    
    public typealias Completion = (Result<Output, Error>) -> Void
    
    public func process(
        _ input: Input,
        completion: @escaping Completion
    ) {
        do {
            let request = try makeRequest(input)
            
            performRequest(request) { [weak self] result in
                
                self?.handle(result, completion)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func handle(
        _ result: HTTPDomain.Result,
        _ completion: @escaping Completion
    ) {
        completion(.init { [mapResponse] in
            
            let (data, response) = try result.get()
            return try mapResponse(data, response)
        })
    }
}
