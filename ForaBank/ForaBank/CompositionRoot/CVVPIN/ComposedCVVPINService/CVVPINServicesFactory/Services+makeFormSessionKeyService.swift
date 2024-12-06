//
//  Services+makeFormSessionKeyService.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation
import GenericRemoteService

extension Services {
    
    typealias CachingFormSessionKeyService = Fetcher<FormSessionKeyService.Payload, FormSessionKeyService.Success, FormSessionKeyService.Failure>
    
    typealias LoadSessionCodeResult = Result<SessionCode, Error>
    typealias LoadSessionCodeCompletion = (LoadSessionCodeResult) -> Void
    typealias LoadSessionCode = (@escaping LoadSessionCodeCompletion) -> Void
    
    typealias ProcessFormSessionKeyError = MappingRemoteServiceError<FormSessionKeyService.APIError>
    typealias ProcessFormSessionKeyResult = Swift.Result<FormSessionKeyService.Response, ProcessFormSessionKeyError>
    typealias ProcessFormSessionKey = (FormSessionKeyService.ProcessPayload, @escaping (ProcessFormSessionKeyResult) -> Void) -> Void
  
    typealias CacheFormSessionKey = (FormSessionKeyService.Success) -> Void
    
    static func makeFormSessionKeyService(
        processFormSessionKey: @escaping ProcessFormSessionKey,
        makeSecretRequestJSON: @escaping FormSessionKeyService.MakeSecretRequestJSON,
        makeSessionKey: @escaping FormSessionKeyService.MakeSessionKey,
        cacheFormSessionKey: @escaping CacheFormSessionKey
    ) -> any CachingFormSessionKeyService {
        
        let formSessionKeyService = FormSessionKeyService(
            makeSecretRequestJSON: makeSecretRequestJSON,
            process: process(payload:completion:),
            makeSessionKey: makeSessionKey
        )
        
        let cachingFormSessionKeyService = FetcherDecorator(
            decoratee: formSessionKeyService,
            handleSuccess: cacheFormSessionKey
        )
        
        return cachingFormSessionKeyService
        
        // MARK: - FormSessionKey Adapters
        
        func process(
            payload: FormSessionKeyService.ProcessPayload,
            completion: @escaping FormSessionKeyService.ProcessCompletion
        ) {
            processFormSessionKey(
                .init(code: payload.code, data: payload.data)
            ) {
                completion($0.mapError { .init($0) })
            }
        }
    }
}

// MARK: - Mappers

private extension FormSessionKeyService.APIError {
    
    init(_ error: MappingRemoteServiceError<FormSessionKeyService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}
