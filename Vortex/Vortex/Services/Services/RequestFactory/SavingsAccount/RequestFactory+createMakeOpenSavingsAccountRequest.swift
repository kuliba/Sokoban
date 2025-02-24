//
//  RequestFactory+createMakeOpenSavingsAccountRequest.swift
//  Vortex
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import Foundation
import RemoteServices
import SavingsServices

extension RequestFactory {

    static func createMakeOpenSavingsAccountRequest(
        payload: MakeOpenSavingsAccountPayload
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.makeOpenSavingsAccountRequest
        let url = try! endpoint.url(withBase: Config.serverAgentEnvironment.baseURL)

        return try RemoteServices.RequestFactory.createMakeOpenSavingsAccountRequest(
            payload: .init(payload),
            url: url)
    }
}

struct MakeOpenSavingsAccountPayload {
    
    let accountID: Int?
    let amount: Decimal?
    let cardID: Int?
    let cryptoVersion: String
    let currencyCode: Int?
    let verificationCode: String
}

private extension SavingsServices.MakeOpenSavingsAccountPayload {
    
    init(_ data: MakeOpenSavingsAccountPayload){
        
        self.init(accountID: data.accountID, amount: data.amount, cardID: data.cardID, cryptoVersion: data.cryptoVersion, currencyCode: data.currencyCode, verificationCode: data.verificationCode)
        
    }
}
