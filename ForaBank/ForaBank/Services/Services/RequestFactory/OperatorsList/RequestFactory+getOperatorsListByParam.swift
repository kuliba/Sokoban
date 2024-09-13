//
//  RequestFactory+getOperatorsListByParam.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 16.02.2024.
//

import Foundation

extension RequestFactory {
    
    static func getOperatorsListByParam(
        categoryType: ServiceCategory.CategoryType
    ) throws -> URLRequest {
        
        try getOperatorsListByParam(categoryType.name)
    }
    
    static func getOperatorsListByParam(
        _ type: String = "housingAndCommunalService"
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("operatorOnly", "true"),
            ("type", type)
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
