//
//  RequestFactory+createGetPrintFormForApplicationOrderingCardRequest.swift
//
//
//  Created by Дмитрий Савушкин on 20.03.2025.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetPrintFormForApplicationOrderingCardRequest(
        payload: GetPrintFormPayload,
        url: URL
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody()
        
        return request
    }
}

public struct GetPrintFormPayload {
    
    public let requestId: String
    
    public init(
        requestId: String
    ) {
        self.requestId = requestId
    }
}

private extension GetPrintFormPayload {
    
    func httpBody() throws -> Data {
        
        var parameters: [String: Any] = ["requestId": requestId]
        
        return try JSONSerialization.data(withJSONObject: parameters as [String: Any])
    }
}
