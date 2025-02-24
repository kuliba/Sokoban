//
//  RequestFactory+createGetPrintFormForSavingsAccountRequest.swift
//
//
//  Created by Andryusina Nataly on 24.02.2025.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetPrintFormForSavingsAccountRequest(
        payload: GetPrintFormPayload,
        url: URL
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody()
        
        return request
    }
}

public struct GetPrintFormPayload {
    
    public let accountId: Int
    public let detailId: Int?
    
    public init(accountId: Int, detailId: Int?) {
        self.accountId = accountId
        self.detailId = detailId
    }
}

private extension GetPrintFormPayload {
    
    func httpBody() throws -> Data {
        
        var parameters: [String: Any] = ["accountId": accountId]
        
        detailId.map { parameters["paymentOperationDetailId"] = $0 }
        
        return try JSONSerialization.data(withJSONObject: parameters as [String: Any])
    }
}
