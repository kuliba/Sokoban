//
//  RequestFactory+getCardStatementForPeriod.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 16.01.2024.
//

import Foundation
import Tagged

extension RequestFactory {
    
    static func getCardStatementForPeriod(
        payload: CardStatementForPeriodDomain.Payload
    ) -> URLRequest {
        
        let endpoint = Services.Endpoint.getCardStatementForPeriod
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = payload.json
        return request
    }
}
