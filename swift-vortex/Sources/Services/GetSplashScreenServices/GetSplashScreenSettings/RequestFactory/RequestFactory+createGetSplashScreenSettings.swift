//
//  RequestFactory+createGetSplashScreenSettings.swift
//  
//
//  Created by Nikolay Pochekuev on 19.02.2025.
//

import Foundation
import RemoteServices
import VortexTools

public extension RequestFactory {
    
    static func createGetSplashScreenSettingsRequest(
        url: URL,
        timePeriod: String
    ) throws -> URLRequest {
        
        let url = try url.appendingQueryItems(parameters: ["enum": timePeriod])
        return createEmptyRequest(.get, with: url)
    }
}
