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
    
    typealias GetCodeService = Fetcher<GetProcessingSessionCodeService.Payload, GetProcessingSessionCodeService.Success, GetProcessingSessionCodeService.Failure>
    
    typealias ProcessGetCodeSuccess = GetProcessingSessionCodeService.Response
    typealias ProcessGetCodeError = MappingRemoteServiceError<GetProcessingSessionCodeService.APIError>
    typealias ProcessGetCodeResult = Result<ProcessGetCodeSuccess, ProcessGetCodeError>
    typealias ProcessGetCodeCompletion = (ProcessGetCodeResult) -> Void
    typealias ProcessGetCode = (@escaping ProcessGetCodeCompletion) -> Void
    
    typealias CacheGetProcessingSessionCode = (GetProcessingSessionCodeService.Response, @escaping (Result<Void, Error>) -> Void) -> Void
    
    static func makeGetCodeService(
        processGetCode: @escaping ProcessGetCode,
        cacheGetProcessingSessionCode: @escaping CacheGetProcessingSessionCode
    ) -> any GetCodeService {
        
        let getCodeService = GetProcessingSessionCodeService(
            process: process(completion:)
        )
        
        let cachingGetCodeService = FetcherDecorator(
            decoratee: getCodeService,
            onSuccess: { success, completion in
                
                cacheGetProcessingSessionCode(success) { _ in completion() }
            }
        )
        
        return cachingGetCodeService
        
        // MARK: - GetProcessingSessionCode Adapters
        
        func process(
            completion: @escaping GetProcessingSessionCodeService.ProcessCompletion
        ) {
            processGetCode {
                
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
