//
//  RequestFactory+getOperatorsListByParam.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 16.02.2024.
//

import Foundation

extension RequestFactory {
    
    static func getOperatorsListByParam(
        _ type: String
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("operatorOnly", "true"),
            ("type", "housingAndCommunalService")
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
    
    // TODO: combine with above, improve API (strong types for type & operatorID)
    static func createGetOperatorsListByParamOperatorOnlyFalseRequest(
        operatorID: String
    ) throws -> URLRequest {
        
        guard !operatorID.isEmpty else {
            struct EmptyOperatorIDError: Error {}
            throw EmptyOperatorIDError()
        }
        
        let parameters: [(String, String)] = [
            ("customerId", operatorID),
            ("operatorOnly", "false"),
            ("type", "housingAndCommunalService")
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
