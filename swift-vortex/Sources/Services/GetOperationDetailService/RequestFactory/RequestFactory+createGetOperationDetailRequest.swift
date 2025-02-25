//
//  RequestFactory+createGetOperationDetailRequest.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetOperationDetailRequest(
        url: URL,
        detailID: String
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try detailID.httpBody
        
        return request
    }
}

private extension String {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "documentId": self
            ] as [String: String])
        }
    }
}
