//
//  Services+makeAuthWithPublicKeyService.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.11.2023.
//

import CVVPIN_Services
import Fetcher
import Foundation

extension Services {
    
    typealias AuthWithPublicKeyService = Fetcher<AuthenticateWithPublicKeyService.Payload, AuthenticateWithPublicKeyService.Success, AuthenticateWithPublicKeyService.Failure>
    typealias PrepareKeyExchange = (@escaping AuthenticateWithPublicKeyService.PrepareKeyExchangeCompletion) -> Void
    typealias AuthRemoteService = Fetcher<Data, AuthenticateWithPublicKeyService.Response, MappingRemoteServiceError<AuthenticateWithPublicKeyService.APIError>>
    typealias CacheAuthSuccess = (AuthenticateWithPublicKeyService.Success) -> Void
    
    static func makeAuthWithPublicKeyService(
        prepareKeyExchange: @escaping PrepareKeyExchange,
        authRemoteService: any AuthRemoteService,
        makeSessionKey: @escaping AuthenticateWithPublicKeyService.MakeSessionKey,
        cache: @escaping CacheAuthSuccess
    ) -> any AuthWithPublicKeyService{
        
        let authenticateWithPublicKeyService = AuthenticateWithPublicKeyService(
            prepareKeyExchange: prepareKeyExchange,
            process: process(data:completion:),
            makeSessionKey: makeSessionKey
        )
        
        let cachingAuthWithPublicKeyService = FetcherDecorator(
            decoratee: authenticateWithPublicKeyService,
            handleSuccess: cache
        )
        
        return cachingAuthWithPublicKeyService
        
        // MARK: - AuthenticateWithPublicKey Adapters
        
        func process(
            data: Data,
            completion: @escaping AuthenticateWithPublicKeyService.ProcessCompletion
        ) {
            authRemoteService.fetch(data) {
                
                completion($0.mapError { .init($0) })
            }
        }
    }
}

// MARK: - Error Mappers

private extension AuthenticateWithPublicKeyService.APIError {
    
    init(_ error: MappingRemoteServiceError<AuthenticateWithPublicKeyService.APIError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .network
            
        case let .mapResponse(mapResponseError):
            self = mapResponseError
        }
    }
}
