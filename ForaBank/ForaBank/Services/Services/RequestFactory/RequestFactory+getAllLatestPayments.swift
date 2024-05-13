//
//  RequestFactory+getAllLatestPayments.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 13.05.2024.
//

import Foundation
import RemoteServices
import OperatorsListComponents

extension RequestFactory {
    
    static func getAllLatestPaymentRequest(
        _ kind: LatestPaymentKind
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            kind.parameterService()
        ]
        
        let endpoint = Services.Endpoint.getAllLatestPayments
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return request
    }
}
