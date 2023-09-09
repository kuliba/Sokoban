//
//  RequestFactory+makeBindPublicKeyWithEventIDRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.08.2023.
//

import CvvPin
import Foundation
import TransferPublicKey

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
        
        guard !payload.eventID.isEmpty else {
            throw PublicKeyWithEventIDError.emptyEventID
        }
        
        guard !payload.key.isEmpty else {
            throw PublicKeyWithEventIDError.emptyKeyString
        }
        
        let base = APIConfig.processingServerURL
        let endpoint = Services.Endpoint.bindPublicKeyWithEventID
        let url = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? payload.json
        
        return request
    }
    
    enum PublicKeyWithEventIDError: Error, Equatable {
        
        case emptyEventID
        case emptyKeyString
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

private extension PublicKeyWithEventID {
    
    var json: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "eventId": eventID.value,
                "data": key.base64String
            ] as [String: Any])
        }
    }
}
