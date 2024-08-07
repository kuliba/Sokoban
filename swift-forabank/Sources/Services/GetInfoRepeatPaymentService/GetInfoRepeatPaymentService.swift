//
//  GetInfoRepeatPaymentService.swift
//  
//
//  Created by Дмитрий Савушкин on 30.07.2024.
//

import Foundation

public final class GetInfoRepeatPaymentService {
    
    public typealias PerformRequest = GetInfoRepeatPaymentDomain.PerformRequest
    public typealias MapResponse = GetInfoRepeatPaymentDomain.MapResponse
    
    private let url: URL
    private let performRequest: PerformRequest
    private let mapResponse: MapResponse
    
    public init(
        url: URL,
        performRequest: @escaping PerformRequest,
        mapResponse: @escaping MapResponse = GetInfoRepeatPaymentMapper.mapResponse
    ) {
        self.url = url
        self.performRequest = performRequest
        self.mapResponse = mapResponse
    }
    
    public typealias Completion = GetInfoRepeatPaymentDomain.Completion
    
    public func process(completion: @escaping Completion) {
        
        performRequest(.init(url: url)) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(GetInfoRepeatPaymentDomain.InfoPaymentError.connectivity))
                
            case let .success((data, httpURLResponse)):
                completion(mapResponse(data, httpURLResponse))
            }
        }
    }
}
