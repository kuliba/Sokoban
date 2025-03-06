//
//  RequestFactory+createGetSplashScreenImageRequest.swift
//
//
//  Created by Nikolay Pochekuev on 04.03.2025.
//

import Foundation
import RemoteServices
import VortexTools

public extension RequestFactory {
    
    static func createGetSplashScreenImageRequest(
        url: URL,
        splash: String
    ) throws -> URLRequest {
        
        let url  = try url.appendingQueryItems(parameters: ["splash": splash])
        
        return createEmptyRequest(.get, with: url)
    }
}
