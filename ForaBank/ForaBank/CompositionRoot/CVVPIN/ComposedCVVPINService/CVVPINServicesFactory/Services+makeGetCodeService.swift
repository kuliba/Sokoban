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
    typealias GetCodeServiceError = MappingRemoteServiceError<GetProcessingSessionCodeService.APIError>
    typealias GetCodeServiceProcess = (@escaping (Swift.Result<GetProcessingSessionCodeService.Response, GetCodeServiceError>) -> Void) -> Void
    
    static func makeGetCodeService(
        getCodeServiceProcess: @escaping GetCodeServiceProcess,
        cacheGetProcessingSessionCode: @escaping CacheGetProcessingSessionCode
    ) -> any GetCodeService {
        
        let getCodeService = GetProcessingSessionCodeService(
            process: process(completion:)
        )
        
        let cachingGetCodeService = FetcherDecorator(
            decoratee: getCodeService,
            handleSuccess: cacheGetProcessingSessionCode
        )
        
        return cachingGetCodeService
        
        // MARK: - GetProcessingSessionCode Adapters
        
        func process(
            completion: @escaping GetProcessingSessionCodeService.ProcessCompletion
        ) {
            getCodeServiceProcess {
                
                completion($0.mapError { .init($0) })
            }
        }
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
