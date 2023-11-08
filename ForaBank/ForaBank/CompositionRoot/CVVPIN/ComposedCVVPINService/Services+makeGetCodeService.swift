//
//  Services+makeGetCodeService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation
import GenericRemoteService

extension Services {
    
    typealias CacheGetProcessingSessionCode = (GetProcessingSessionCodeService.Response) -> Void
    typealias GetCodeService = Fetcher<GetProcessingSessionCodeService.Payload, GetProcessingSessionCodeService.Success, GetProcessingSessionCodeService.Failure>
    
    static func makeGetCodeService(
        getCodeRemoteService: GetCodeRemoteService,
        cacheGetProcessingSessionCode: @escaping CacheGetProcessingSessionCode
    ) -> any GetCodeService {
        
        let getCodeService = GetProcessingSessionCodeService(
            process: process(completion:)
        )
        
        let cachingGetCodeService = FetcherDecorator(
            decoratee: getCodeService,
            cache: cacheGetProcessingSessionCode
        )
        
        return cachingGetCodeService
        
        // MARK: - GetProcessingSessionCode Adapters
        
        func process(
            completion: @escaping GetProcessingSessionCodeService.ProcessCompletion
        ) {
            getCodeRemoteService.process {
                
                completion($0.mapError { .init($0) })
            }
        }
    }
}

// MARK: - Adapters

private extension RemoteService where Input == Void {
    
    func process(completion: @escaping ProcessCompletion) {
        
        process((), completion: completion)
    }
}

// MARK: - Mappers

private extension GetProcessingSessionCodeService.APIError {
    
    init(_ error: MappingRemoteServiceError<GetProcessingSessionCodeService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}
