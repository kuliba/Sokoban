//
//  RequestFactory+createGetSplashScreenTimePeriodsRequest.swift
//
//
//  Created by Nikolay Pochekuev on 18.02.2025.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetSplashScreenTimePeriodsRequest(
        url: URL
    ) -> URLRequest {
        
        createEmptyRequest(.get, with: url)
    }
}
