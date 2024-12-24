//
//  RequestFactory+getOperatorsListByParam.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 16.02.2024.
//

import VortexTools
import Foundation
import SerialComponents

extension RequestFactory {
    
    struct GetOperatorsListByParamPayload: Equatable, WithSerial {
        
        let serial: String?
        let category: ServiceCategory
    }

    static func getOperatorsListByParam(
        payload: GetOperatorsListByParamPayload
    ) throws -> URLRequest {
        
        try getOperatorsListByParam(
            serial: payload.serial,
            type: payload.category.type
        )
    }
    
    static func getOperatorsListByParam(
        serial: String? = nil,
        type: String
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("operatorOnly", "true"),
            ("type", type),
            serial.map { ("serial", $0) }
        ].compactMap { $0 }
        
        let endpoint = Services.Endpoint.getOperatorsListByParam
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return request
    }
    
    // TODO: combine with above, improve API (strong types for type & operatorID)
    static func createGetOperatorsListByParamOperatorOnlyFalseRequest(
        `operator`: UtilityPaymentProvider
    ) throws -> URLRequest {
        
        guard !`operator`.id.isEmpty else {
            struct EmptyOperatorIDError: Error {}
            throw EmptyOperatorIDError()
        }
        
        let parameters: [(String, String)] = [
            ("customerId", `operator`.id),
            ("operatorOnly", "false"),
            ("type", `operator`.type)
        ]
        
        let endpoint = Services.Endpoint.getOperatorsListByParam
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return request
    }
}
