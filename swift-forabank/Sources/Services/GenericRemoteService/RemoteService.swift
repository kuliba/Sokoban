//
//  RemoteService.swift
//  
//
//  Created by Igor Malyarov on 01.08.2023.
//

import Foundation

public final class RemoteService<Input, Output, CreateRequestError, PerformRequestError, MapResponseError>
where CreateRequestError: Error,
      PerformRequestError: Error,
      MapResponseError: Error {
    
    public typealias CreateRequest = (Input) -> Result<URLRequest, CreateRequestError>
    
    public typealias Response = (Data, HTTPURLResponse)
    
    public typealias PerformResult = Result<Response, PerformRequestError>
    public typealias PerformCompletion = (PerformResult) -> Void
    public typealias PerformRequest = (URLRequest, @escaping PerformCompletion) -> Void
    
    public typealias MapResponse = (Response) -> Result<Output, MapResponseError>
    
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
}

public extension RemoteService {
    
    typealias ProcessError = RemoteServiceError<CreateRequestError, PerformRequestError, MapResponseError>
    typealias ProcessResult = Result<Output, ProcessError>
    typealias ProcessCompletion = (ProcessResult) -> Void
    
    func process(
        _ input: Input,
        completion: @escaping ProcessCompletion
    ) {
        let request = createRequest(input)
        
        switch request {
        case let .failure(createRequestError):
            completion(.failure(.createRequest(createRequestError)))
            
        case let .success(urlRequest):
            performRequest(urlRequest) { [weak self] result in
                
                self?.handle(result, with: completion)
            }
        }
    }
}

public enum RemoteServiceError<CreateRequestError, PerformRequestError, MapResponseError>: Error {
    
    case createRequest(CreateRequestError)
    case performRequest(PerformRequestError)
    case mapResponse(MapResponseError)
}

private extension RemoteService {
    
    func handle(
        _ result: PerformResult,
        with completion: @escaping ProcessCompletion
    ) {
        switch result {
        case let .failure(error):
            completion(.failure(.performRequest(error)))
            
        case let .success(response):
            let result = mapResponse(response)
            
            switch result {
            case let .failure(mapResponseError):
                completion(.failure(.mapResponse(mapResponseError)))
                
            case let .success(output):
                completion(.success(output))
            }
        }
    }
}

public extension RemoteService {
    
    func process(
        _ input: Input
    ) async throws -> Output {
        
        return try await withCheckedThrowingContinuation { continuation in
            
            process(input, completion: continuation.resume(with:))
        }
    }
}
