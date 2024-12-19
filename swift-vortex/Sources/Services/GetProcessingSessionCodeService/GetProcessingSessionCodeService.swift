//
//  GetProcessingSessionCodeService.swift
//  
//
//  Created by Igor Malyarov on 31.07.2023.
//

import Foundation

public final class GetProcessingSessionCodeService {
    
    public typealias PerformRequest = SessionCodeDomain.PerformRequest
    public typealias MapResponse = SessionCodeDomain.MapResponse
    
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
    
    public typealias Completion = SessionCodeDomain.Completion
    
    public func process(completion: @escaping Completion) {
        
        performRequest(.init(url: url)) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(SessionCodeDomain.Error.connectivity))
                
            case let .success((data, httpURLResponse)):
                completion(mapResponse(data, httpURLResponse))
            }
        }
    }
}
