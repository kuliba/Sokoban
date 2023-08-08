//
//  RequestFactory+makeSecretRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.08.2023.
//

import CvvPin
import Foundation

extension RequestFactory {
    
    static func makeSecretRequest(
        from secretRequest: SecretRequest
    ) throws -> URLRequest {
        
        guard !secretRequest.code.isEmpty else {
            throw SecretRequestError.emptyCode
        }
        
        guard !secretRequest.data.isEmpty else {
            throw SecretRequestError.emptyData
        }
        
        let base = APIConfig.processingServerURL
        let endpoint = Services.Endpoint.formSessionKey
        let url = try! endpoint.url(withBase: base)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = secretRequest.json
        
        return request
    }
    
    enum SecretRequestError: Error, Equatable {
        
        case emptyCode
        case emptyData
    }
}

private extension SecretRequest {
    
    var json: Data? {
        
        try? JSONSerialization.data(withJSONObject: [
            "code": code,
            "data": data
        ] as [String: Any])
    }
}
