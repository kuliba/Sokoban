//
//  RequestFactory+getDigitalCardLanding.swift
//
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetDigitalCardLandingRequest(
        url: URL
    ) throws -> URLRequest {
        
        let request = createEmptyRequest(.get, with: url)
        return request
    }
}
