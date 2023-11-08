//
//  Services+makeBindPublicKeyService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation
import GenericRemoteService

extension Services {
    
    typealias BindPublicKeyService = Fetcher<BindPublicKeyWithEventIDService.Payload, BindPublicKeyWithEventIDService.Success, BindPublicKeyWithEventIDService.Failure>
    typealias OnBindKeyFailure = (BindPublicKeyWithEventIDService.Failure) -> Void
    
    static func makeBindPublicKeyService(
        sessionIDLoader: any Loader<SessionID>,
        bindPublicKeyWithEventIDRemoteService: BindPublicKeyWithEventIDRemoteService,
        makeSecretJSON: @escaping BindPublicKeyWithEventIDService.MakeSecretJSON,
        onBindKeyFailure: @escaping OnBindKeyFailure
    ) -> any BindPublicKeyService {
        
        let bindPublicKeyWithEventIDService = BindPublicKeyWithEventIDService(
            loadEventID: loadEventID(completion:),
            makeSecretJSON: makeSecretJSON,
            process: process(payload:completion:)
        )
        
        let rsaKeyPairCacheCleaningBindPublicKeyService = FetcherDecorator(
            decoratee: bindPublicKeyWithEventIDService,
            handleFailure: onBindKeyFailure
        )
        
        return rsaKeyPairCacheCleaningBindPublicKeyService
        
        // MARK: - BindPublicKeyWithEventID Adapters
        
        func loadEventID(
            completion: @escaping BindPublicKeyWithEventIDService.EventIDCompletion
        ) {
            sessionIDLoader.load {
                
                completion($0.map { .init(eventIDValue: $0.value) })
            }
        }
        
        func process(
            payload: BindPublicKeyWithEventIDService.ProcessPayload,
            completion: @escaping BindPublicKeyWithEventIDService.ProcessCompletion
        ){
            bindPublicKeyWithEventIDRemoteService.process(payload) {
                
                completion($0.mapError { .init($0) })
            }
        }
    }
}

// MARK: - Mappers

private extension BindPublicKeyWithEventIDService.APIError {
    
    init(_ error: MappingRemoteServiceError<BindPublicKeyWithEventIDService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}
