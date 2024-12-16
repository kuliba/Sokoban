//
//  RemoteSessionCodeLoader.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

import Foundation

public final class RemoteSessionCodeLoader<APISessionCode: Decodable> {
    
    public typealias SessionCodeAPIClient = APIClient<APISessionCode, Int>
    public typealias SessionCodeMapper = (APISessionCode) -> GetProcessingSessionCodeDomain.SessionCode
    
    private let api: any SessionCodeAPIClient
    private let sessionCodeMapper: SessionCodeMapper
    
    public init(
        api: any SessionCodeAPIClient,
        sessionCodeMapper: @escaping SessionCodeMapper
    ) {
        self.api = api
        self.sessionCodeMapper = sessionCodeMapper
    }
}

extension RemoteSessionCodeLoader: SessionCodeLoader {
    
    public func load(completion: @escaping LoadCompletion) {
        
        api.data { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                completion(.failure(LoadError.connectivity))
                
            case let .success(response):
                completion(map(response))
            }
        }
    }
    
    private typealias LoadResult = SessionCodeLoader.Result
    
    private func map(
        _ response: API.ServerResponse<APISessionCode, Int>
    ) -> LoadResult {
        
        switch (response.statusCode, response.payload) {
        case (.ok, .none):
            return .failure(LoadError.invalidData)
            
        case (.other, _):
            return .failure(LoadError.invalidData)
            
        case let (.ok, .some(sessionCode)):
            return map(sessionCode)
        }
    }
    
    private func map(_ sessionCode: APISessionCode) -> LoadResult {
        
        let sessionCode = sessionCodeMapper(sessionCode)
        
        if sessionCode.value.isEmpty {
            return .failure(LoadError.invalidData)
        } else {
            return .success(sessionCode)
        }
    }
    
    public enum LoadError: Swift.Error {
        
        case connectivity
        case invalidData
    }
}
