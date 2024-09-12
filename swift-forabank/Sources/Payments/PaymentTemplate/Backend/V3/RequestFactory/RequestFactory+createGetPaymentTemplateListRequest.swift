//
//  RequestFactory+createGetPaymentTemplateListRequest.swift
//
//
//  Created by Igor Malyarov on 05.09.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetPaymentTemplateListRequest(
        url: URL
    ) throws -> URLRequest {
        
        createEmptyRequest(.get, with: url)
    }
}
