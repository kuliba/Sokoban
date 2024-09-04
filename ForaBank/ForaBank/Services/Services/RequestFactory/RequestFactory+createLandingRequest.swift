//
//  RequestFactory+createLandingRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.09.2023.
//

import Foundation

extension RequestFactory {
    
    static func createLandingRequest(
        _ input: (
        serial: String,
        abroadType: AbroadType)
    ) throws -> URLRequest {
        
        let parameters: [(String, String)] = [
            ("serial", input.serial),
            ("type", input.abroadType.rawValue)
        ]
        let endpoint = Services.Endpoint.createLandingRequest
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL,
            parameters: parameters)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }
}

extension AbroadType {
    
    var rawValue: String {
        
        switch self {
        case .orderCard:            return "abroadOrderCard"
        case .transfer:             return "abroadTransfer"
        case .sticker:              return "abroadSticker"
            
        case let .control(cardType):
            switch cardType {
            case .additionalOther:           return "CONTROL_ADDITIONAL_OTHER_CARD"
            case .additionalSelf:            return "CONTROL_ADDITIONAL_SELF_CARD"
            case .additionalSelfAccOwn:      return "CONTROL_ADDITIONAL_SELF_ACC_OWN_CARD"
            case .main:                      return "CONTROL_MAIN_CARD"
            case .regular:                   return "CONTROL_REGULAR_CARD"
            case .additionalCorporate:       return "CONTROL_ADDITIONAL_CORPORATE_CARD"
            case .corporate:                 return "CONTROL_CORPORATE_CARD"
            case .individualBusinessman:     return "CONTROL_INDIVIDUAL_BUSINESSMAN_CARD"
            case .individualBusinessmanMain: return "CONTROL_INDIVIDUAL_BUSINESSMAN_MAIN_CARD"
            }
            
        case let .limit(cardType):
            switch cardType {
            case .additionalOther:           return "LIMIT_ADDITIONAL_OTHER_CARD"
            case .additionalSelf:            return "LIMIT_ADDITIONAL_SELF_CARD"
            case .additionalSelfAccOwn:      return "LIMIT_ADDITIONAL_SELF_ACC_OWN_CARD"
            case .main:                      return "LIMIT_MAIN_CARD"
            case .regular:                   return "LIMIT_REGULAR_CARD"
            case .additionalCorporate:       return "LIMIT_ADDITIONAL_CORPORATE_CARD"
            case .corporate:                 return "LIMIT_CORPORATE_CARD"
            case .individualBusinessman:     return "LIMIT_INDIVIDUAL_BUSINESSMAN_CARD"
            case .individualBusinessmanMain: return "LIMIT_INDIVIDUAL_BUSINESSMAN_MAIN_CARD"
            }
        }
    }
}
