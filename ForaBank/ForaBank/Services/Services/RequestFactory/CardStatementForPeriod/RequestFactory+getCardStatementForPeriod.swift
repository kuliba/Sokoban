//
//  RequestFactory+getCardStatementForPeriod.swift
//  Vortex
//
//  Created by Andryusina Nataly on 16.01.2024.
//

import Foundation
import Tagged
import CardStatementAPI

extension RequestFactory {
    
    static func getCardStatementForPeriod(
        payload: CardStatementAPI.CardStatementForPeriodPayload
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getCardStatementForPeriod
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try payload.httpBody
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
}
