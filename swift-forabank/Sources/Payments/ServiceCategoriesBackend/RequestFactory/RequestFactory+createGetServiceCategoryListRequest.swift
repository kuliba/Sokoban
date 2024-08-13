//
//  RequestFactory+createGetServiceCategoryListRequest.swift
//
//
//  Created by Igor Malyarov on 13.08.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetServiceCategoryListRequest(
        url: URL
    ) throws -> URLRequest {
        
        createEmptyRequest(.get, with: url)
    }
}

