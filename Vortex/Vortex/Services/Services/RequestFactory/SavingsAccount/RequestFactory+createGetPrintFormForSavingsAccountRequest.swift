//
//  RequestFactory+createGetPrintFormForSavingsAccountRequest.swift
//  Vortex
//
//  Created by Andryusina Nataly on 25.02.2025.
//

import Foundation
import SavingsServices
import RemoteServices

extension RequestFactory {
        
    static func createGetPrintFormForSavingsAccountRequest(
        accountID: String,
        detailID: Int?
    ) throws -> URLRequest {
                
        let endpoint = Services.Endpoint.getPrintFormForSavingsAccountRequest
        let url = try! endpoint.url(withBase: Config.serverAgentEnvironment.baseURL)

        return try RemoteServices.RequestFactory.createGetPrintFormForSavingsAccountRequest(
            payload: .init(accountId: accountID, detailId: detailID),
            url: url)
    }
}
