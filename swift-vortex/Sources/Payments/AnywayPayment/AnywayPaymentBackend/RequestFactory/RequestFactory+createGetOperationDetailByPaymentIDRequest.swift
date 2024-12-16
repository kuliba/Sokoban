//
//  RequestFactory+createGetOperationDetailByPaymentIDRequest.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import Foundation
import RemoteServices
import Tagged

public extension RequestFactory {
    
    static func createGetOperationDetailByPaymentIDRequest(
        url: URL,
        payload: OperationDetailID
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

public extension RequestFactory {
    
    typealias OperationDetailID = Tagged<_OperationDetailID, Int>
    enum _OperationDetailID {}
}

private extension RequestFactory.OperationDetailID {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "paymentOperationDetailId": rawValue
            ] as [String: Int])
        }
    }
}
