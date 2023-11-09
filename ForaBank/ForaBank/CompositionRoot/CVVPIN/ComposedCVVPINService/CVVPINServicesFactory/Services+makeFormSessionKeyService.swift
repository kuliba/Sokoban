//
//  Services+makeFormSessionKeyService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation
import GenericRemoteService

extension Services {
    
    typealias CachingFormSessionKeyService = Fetcher<FormSessionKeyService.Payload, FormSessionKeyService.Success, FormSessionKeyService.Failure>
    typealias FormSessionKeyProcessError = MappingRemoteServiceError<FormSessionKeyService.APIError>
    typealias FormSessionKeyProcessResult = Swift.Result<FormSessionKeyService.Response, FormSessionKeyProcessError>
    typealias FormSessionKeyProcess = (FormSessionKeyService.ProcessPayload, @escaping (FormSessionKeyProcessResult) -> Void) -> Void
    typealias CacheFormSessionKeySuccess = (FormSessionKeyService.Success) -> Void
    
    static func makeFormSessionKeyService(
        sessionCodeLoader: any Loader<SessionCode>,
        formSessionKeyProcess: @escaping FormSessionKeyProcess,
        makeSecretRequestJSON: @escaping FormSessionKeyService.MakeSecretRequestJSON,
        makeSessionKey: @escaping FormSessionKeyService.MakeSessionKey,
        cacheFormSessionKeySuccess: @escaping CacheFormSessionKeySuccess
    ) -> any CachingFormSessionKeyService {
        
        let formSessionKeyService = FormSessionKeyService(
            loadCode: loadCode(completion:),
            makeSecretRequestJSON: makeSecretRequestJSON,
            process: process(payload:completion:),
            makeSessionKey: makeSessionKey
        )
        
        let cachingFormSessionKeyService = FetcherDecorator(
            decoratee: formSessionKeyService,
            handleSuccess: cacheFormSessionKeySuccess
        )
        
        return cachingFormSessionKeyService
        
        // MARK: - FormSessionKey Adapters
        
        func loadCode(
            completion: @escaping FormSessionKeyService.CodeCompletion
        ) {
            sessionCodeLoader.load { result in
                
                completion(
                    result
                        .map(\.sessionCodeValue)
                        .map(FormSessionKeyService.Code.init)
                )
            }
        }
        
        func process(
            payload: FormSessionKeyService.ProcessPayload,
            completion: @escaping FormSessionKeyService.ProcessCompletion
        ) {
            formSessionKeyProcess(
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
