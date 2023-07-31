//
//  GetProcessingSessionCodeService.swift
//  
//
//  Created by Igor Malyarov on 31.07.2023.
//

import Foundation

public final class GetProcessingSessionCodeService {
    
    public typealias Response = Swift.Result<(Data, HTTPURLResponse), Swift.Error>
    public typealias ResponseCompletion = (Response) -> Void
    public typealias PerformRequest = (URLRequest, @escaping ResponseCompletion) -> Void
    
    public typealias Result = Swift.Result<GetProcessingSessionCode, Error>
    public typealias MapResponse = (Data, HTTPURLResponse) -> Result
    
    private let url: URL
    private let performRequest: PerformRequest
    private let mapResponse: MapResponse
    
    public init(
        url: URL,
        performRequest: @escaping PerformRequest,
        mapResponse: @escaping MapResponse = GetProcessingSessionCodeMapper.mapResponse
    ) {
        self.url = url
        self.performRequest = performRequest
        self.mapResponse = mapResponse
    }
    
    public typealias Completion = (Result) -> Void
    
    public func process(completion: @escaping Completion) {
        
        performRequest(.init(url: url)) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
                
            case let .success((data, httpURLResponse)):
                completion(mapResponse(data, httpURLResponse))
            }
        }
    }
    
    public enum Error: Swift.Error, Equatable {
        
        case connectivity
        case invalidData(statusCode: Int)
        case unknownStatusCode(Int)
        case serverError(statusCode: Int, errorMessage: String)
    }
}

