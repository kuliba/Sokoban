//
//  RequestFactory+createSaveConsentsRequest.swift
//  ForaBank
//
//  Created by Valentin Ozerov on 28.10.2024.
//

import Foundation
import RemoteServices
import CollateralLoanLandingSaveConsentsBackend

extension RequestFactory {
    
    static func createSaveConsentsRequest(
        with payload: RemoteServices.RequestFactory.SaveConsentsPayload
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.saveConsents
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        return try RemoteServices.RequestFactory.createCollateralLoanLandingSaveConsentsRequest(
            url: url,
            payload: payload
        )
    }
}
