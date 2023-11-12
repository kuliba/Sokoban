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
    
    typealias ProcessBindPublicKeyError = MappingRemoteServiceError<BindPublicKeyWithEventIDService.APIError>
    typealias ProcessBindPublicKey = (BindPublicKeyWithEventIDService.ProcessPayload, @escaping (Result<Void, ProcessBindPublicKeyError>) -> Void) -> Void
    
    static func makeBindPublicKeyService(
        sessionIDLoader: any Loader<SessionID>,
        processBindPublicKey: @escaping ProcessBindPublicKey,
        makeSecretJSON: @escaping BindPublicKeyWithEventIDService.MakeSecretJSON
    ) -> any BindPublicKeyService {
        
        return BindPublicKeyWithEventIDService(
            loadEventID: loadEventID(completion:),
            makeSecretJSON: makeSecretJSON,
            process: process(payload:completion:)
        )
        
        // MARK: - BindPublicKeyWithEventID Adapters
        
        func loadEventID(
            completion: @escaping BindPublicKeyWithEventIDService.EventIDCompletion
        ) {
            sessionIDLoader.load {
                
                completion($0.map { .init(eventIDValue: $0.sessionIDValue) })
            }
        }
        
        func process(
            payload: BindPublicKeyWithEventIDService.ProcessPayload,
            completion: @escaping BindPublicKeyWithEventIDService.ProcessCompletion
        ){
            processBindPublicKey(payload) {
                
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
