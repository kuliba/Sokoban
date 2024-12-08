//
//  RequestFactory+createGetSavingLandingRequest.swift
//
//
//  Created by Andryusina Nataly on 21.11.2024.
//

import Foundation
import VortexTools
import RemoteServices

public extension RequestFactory {
    
    static func createGetSavingLandingRequest(
        parameters: [String: String],
        url: URL
    ) throws -> URLRequest {
        
        let url = try url.appendingQueryItems(parameters: parameters)
        return createEmptyRequest(.get, with: url)
    }
}
