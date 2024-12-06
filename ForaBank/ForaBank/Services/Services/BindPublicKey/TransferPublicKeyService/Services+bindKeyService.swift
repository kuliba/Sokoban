//
//  Services+bindKeyService.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.09.2023.
//

import CvvPin
import Foundation
import GenericRemoteService
import TransferPublicKey

extension Services {
    
    typealias Input = BindKeyDomain<KeyExchangeDomain.KeyExchange.EventID>.PublicKeyWithEventID
    typealias BindKeyService = RemoteServiceOf<Input, Void>
    
    static func bindKeyService(
        httpClient: HTTPClient
    ) -> BindKeyService {
        
        typealias LoggingRequestCreator = LoggingDecoratedRequestCreator<BindKeyExchangePayload>
        
        let loggingRequestCreator = LoggingRequestCreator(
            log: LoggerAgent.shared.log,
            decoratee: RequestFactory.makeBindPublicKeyWithEventIDRequest
        )
        
        return .init(
            createRequest: loggingRequestCreator.createRequest,
            performRequest: httpClient.performRequest,
            mapResponse: BindPublicKeyWithEventIDMapper.map
        )
    }
}

private extension BindPublicKeyWithEventIDMapper {
    
    static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) throws {
        
        guard let error = map(data, response) else {
            return
        }
        
        throw error
    }
}
