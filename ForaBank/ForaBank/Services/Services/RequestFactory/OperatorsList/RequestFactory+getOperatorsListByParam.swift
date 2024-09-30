//
//  RequestFactory+getOperatorsListByParam.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 16.02.2024.
//

import ForaTools
import Foundation

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
            type: payload.category.type.name
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

extension ServiceCategory.CategoryType {
    
    var name: String {
        
        switch self {
        case .charity:                   return "charity"
        case .digitalWallets:            return "digitalWallets"
        case .education:                 return "education"
        case .housingAndCommunalService: return "housingAndCommunalService"
        case .internet:                  return "internet"
        case .mobile:                    return "mobile"
        case .networkMarketing:          return "networkMarketing"
        case .qr:                        return "qr"
        case .repaymentLoansAndAccounts: return "repaymentLoansAndAccounts"
        case .security:                  return "security"
        case .socialAndGames:            return "socialAndGames"
        case .taxAndStateService:        return "taxAndStateService"
        case .transport:                 return "transport"
        }
    }
}
