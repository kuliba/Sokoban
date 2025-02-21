//
//  RequestFactory+createMakeOpenSavingsAccountRequest.swift
//
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import Foundation
import VortexTools
import RemoteServices

public extension RequestFactory {
    
    static func createMakeOpenSavingsAccountRequest(
        payload: MakeOpenSavingsAccountPayload,
        url: URL
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody()
        request.httpMethod = "POST"
        
        return request
    }
}

private extension MakeOpenSavingsAccountPayload {
    
    func httpBody() throws -> Data {
        
        var parameters: [String: Any] = [
            "cryptoVersion": cryptoVersion,
            "verificationCode": verificationCode
        ]
        
        accountID.map { parameters["sourceAccountId"] = $0 }
        cardID.map { parameters["sourceCardId"] = $0 }
        currencyCode.map { parameters["currencyCode"] = $0 }
        amount.map { parameters["amount"] = $0 }
        
        return try JSONSerialization.data(
            withJSONObject: parameters as [String: Any]
        )
    }
}
