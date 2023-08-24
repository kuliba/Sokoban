//
//  RemoteService.swift
//  
//
//  Created by Igor Malyarov on 01.08.2023.
//

import Foundation

public final class RemoteService<Input, Output> {
    
    public typealias CreateRequest = (Input) throws -> HTTPDomain.Request
    public typealias PerformRequest = (HTTPDomain.Request, @escaping HTTPDomain.Completion) -> Void
    public typealias MapResponse = (HTTPDomain.Response) throws -> Output
    
    private let createRequest: CreateRequest
    private let performRequest: PerformRequest
    private let mapResponse: MapResponse
    
    public init(
        createRequest: @escaping CreateRequest,
        performRequest: @escaping PerformRequest,
        mapResponse: @escaping MapResponse
    ) {
        self.createRequest = createRequest
        self.performRequest = performRequest
        self.mapResponse = mapResponse
    }
    
    public typealias Completion = (Result<Output, Error>) -> Void
    
    public func process(
        _ input: Input,
        completion: @escaping Completion
    ) {
        do {
            let request = try createRequest(input)
            
            performRequest(request) { [weak self] result in
                
                self?.handle(result, with: completion)
            }
        } catch {
            
            completion(.failure(error))
        }
    }
    
    private func handle(
        _ result: HTTPDomain.Result,
        with completion: @escaping Completion
    ) {
        completion(.init { [mapResponse] in
            
            let (data, response) = try result.get()
            return try mapResponse((data, response))
        })
    }
}
