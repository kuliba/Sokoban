//
//  RequestFactory+createGetSavingsAccountInfoRequest.swift
//
//
//  Created by Andryusina Nataly on 25.02.2025.
//

import Foundation
import VortexTools
import RemoteServices

public struct GetSavingsAccountInfoPayload {
    
    public let accountID: String
    
    public init(accountID: String) {
        self.accountID = accountID
    }
}

public extension RequestFactory {
    
    static func createGetSavingsAccountInfoRequest(
        payload: GetSavingsAccountInfoPayload,
        url: URL
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody()
        
        return request
    }
}

private extension GetSavingsAccountInfoPayload {
    
    func httpBody() throws -> Data {
        
        let parameters: [String: String] = ["accountNumber": accountID]
        
        return try JSONSerialization.data(withJSONObject: parameters as [String: String])
    }
}
