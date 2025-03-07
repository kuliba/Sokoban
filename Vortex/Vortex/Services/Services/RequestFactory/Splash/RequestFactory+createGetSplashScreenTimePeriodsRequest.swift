//
//  RequestFactory+createGetSplashScreenTimePeriodsRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.03.2025.
//

import Foundation
import GetSplashScreenServices
import RemoteServices

extension RequestFactory {
    
    static func createGetSplashScreenTimePeriodsRequest(
        serial: String?
    ) throws -> URLRequest {
        
        let base = Config.serverAgentEnvironment.baseURL
        let endpoint = Services.Endpoint.getSplashScreenTimePeriods
        let endpointURL = try! endpoint.url(withBase: base)
        let url = try endpointURL.appendingSerial(serial)
        
        return RemoteServices.RequestFactory.createGetSplashScreenTimePeriodsRequest(url: url)
    }
}
