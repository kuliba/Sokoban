//
//  RequestFactory+createBindPublicKeyWithEventIDRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 05.08.2023.
//

import CvvPin
import Foundation
import TransferPublicKey
import URLRequestFactory

typealias BindKeyExchangePayload = BindKeyDomain<KeyExchangeDomain.KeyExchange.EventID>.Payload

extension RequestFactory {
    
    static func makeBindPublicKeyWithEventIDRequest(
        with payload: BindKeyExchangePayload
    ) throws -> URLRequest {
        
        try makeBindPublicKeyWithEventIDRequest(
            with: .init(payload)
        )
    }
    
    static func makeBindPublicKeyWithEventIDRequest(
        with payload: PublicKeyWithEventID
    ) throws -> URLRequest {
        
        let factory = try factory(for: .bindPublicKeyWithEventID)
        
        return try factory.makeRequest(
            for: .bindPublicKeyWithEventID(.init(
                eventID: .init(value: payload.eventID.value),
                key: .init(value: payload.key.keyData)
            ))
        )
    }
}

// MARK: - Adapters

private extension PublicKeyWithEventID {
    
    init(_ payload: BindKeyExchangePayload) {
        
        self.init(
            key: .init(keyData: payload.data),
            eventID: .init(value: payload.eventID.value)
        )
    }
}
