//
//  RequestFactory+makeBindPublicKeyWithEventIDRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.08.2023.
//

import CvvPin
import Foundation
import TransferPublicKey

extension RequestFactory {
    
    static func makeBindPublicKeyWithEventIDRequest(
        with publicKeyWithEventID: BindKeyDomain<KeyExchangeDomain.KeyExchange.EventID>.PublicKeyWithEventID
    ) throws -> URLRequest {
        
        try makeBindPublicKeyWithEventIDRequest(
            with: .init(publicKeyWithEventID)
        )
    }
    
    static func makeBindPublicKeyWithEventIDRequest(
        with publicKeyWithEventID: PublicKeyWithEventID
    ) throws -> URLRequest {
        
        guard !publicKeyWithEventID.eventID.isEmpty else {
            throw PublicKeyWithEventIDError.emptyEventID
        }
        
        guard !publicKeyWithEventID.keyString.isEmpty else {
            throw PublicKeyWithEventIDError.emptyKeyString
        }
        
        let base = APIConfig.processingServerURL
        let endpoint = Services.Endpoint.bindPublicKeyWithEventID
        let url = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = publicKeyWithEventID.json
        
        return request
    }
    
    enum PublicKeyWithEventIDError: Error, Equatable {
        
        case emptyEventID
        case emptyKeyString
    }
}

private extension PublicKeyWithEventID {
    
    init(
        _ transferPublicKeyWithEventID: BindKeyDomain<KeyExchangeDomain.KeyExchange.EventID>.PublicKeyWithEventID
    ) {
        self.init(
            keyString: transferPublicKeyWithEventID.data.base64EncodedString(),
            eventID: .init(value: transferPublicKeyWithEventID.eventID.value)
        )
    }
}

private extension PublicKeyWithEventID {
    
    var json: Data? {
        
        try? JSONSerialization.data(withJSONObject: [
            "eventId": eventID.value,
            "data": keyString
        ] as [String: Any])
    }
}
