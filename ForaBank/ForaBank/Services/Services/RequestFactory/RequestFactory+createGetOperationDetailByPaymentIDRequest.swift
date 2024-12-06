//
//  RequestFactory+createGetOperationDetailByPaymentIDRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.11.2023.
//

import Foundation
import Tagged

extension RequestFactory {
    
    static func createGetOperationDetailByPaymentIDRequest(
        paymentID: PaymentID
    ) throws -> URLRequest {

        guard !paymentID.isEmpty
        else {
            throw GetOperationDetailByPaymentIDError.invalidDocumentID
        }
        
        let endpoint = Services.Endpoint.getOperationDetailByPaymentID
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "paymentOperationDetailId": paymentID.rawValue
        ] as [String: String])
        
        return request
    }
    
    enum GetOperationDetailByPaymentIDError: Error {
        
        case invalidDocumentID
    }
}

