//
//  RequestFactory+createGetOpenAccountFormRequest.swift
//
//
//  Created by Andryusina Nataly on 22.11.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetOpenAccountFormRequest(
        url: URL
    ) throws -> URLRequest {
        
        return createEmptyRequest(.get, with: url)
    }
}
