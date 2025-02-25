//
//  RequestFactory+createGetOperationDetailByPaymentIDRequestModule.swift
//  Vortex
//
//  Created by Igor Malyarov on 26.03.2024.
//

import AnywayPaymentBackend
import Foundation
import GetOperationDetailService
import RemoteServices

extension Vortex.RequestFactory {
    
    static func createGetOperationDetailByPaymentIDRequestModule(
        _ payload: RemoteServices.RequestFactory.OperationDetailID
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getOperationDetailByPaymentID
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createGetOperationDetailByPaymentIDRequest(
            url: endpointURL,
            payload: payload
        )
    }
    
    static func createGetOperationDetailByPaymentIDRequestV3(
        _ payload: RemoteServices.RequestFactory.OperationDetailID
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getOperationDetailByPaymentIDV3
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createGetOperationDetailByPaymentIDRequest(
            url: endpointURL,
            payload: payload
        )
    }
    
    static func createGetOperationDetailRequestV3(
        detailID: String
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getOperationDetailV3
        let endpointURL = try! endpoint.url(withBase: base)
        
        return try RemoteServices.RequestFactory.createGetOperationDetailRequest(
            url: endpointURL,
            detailID: detailID
        )
    }
}
