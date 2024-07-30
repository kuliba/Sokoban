//
//  RequestFactory+getInfoForRepeatPayment.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 30.07.2024.
//

import Foundation
import RemoteServices

extension RequestFactory {
    
    static func getInfoForRepeatPayment(
        _ payload: InfoForRepeatPaymentPayload
    ) -> URLRequest {
        
        let endpoint = Services.Endpoint.getAllLatestPayments
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? payload.httpBody
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
        
    }
}

public struct InfoForRepeatPaymentPayload: Equatable {
    
    public let paymentOperationDetailId: Int
    
    public init(paymentOperationDetailId: Int) {
        self.paymentOperationDetailId = paymentOperationDetailId
    }
}

public extension InfoForRepeatPaymentPayload {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "paymentOperationDetailId": "\(paymentOperationDetailId)"
            ] as [String: String])
        }
    }
}
