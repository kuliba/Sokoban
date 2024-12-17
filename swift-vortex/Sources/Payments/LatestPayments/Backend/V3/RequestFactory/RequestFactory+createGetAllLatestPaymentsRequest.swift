//
//  RequestFactory+createGetAllLatestPaymentsRequest.swift
//  
//
//  Created by Igor Malyarov on 07.09.2024.
//

import ForaTools
import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetAllLatestPaymentsRequest(
        parameters: [String],
        url: URL
    ) throws -> URLRequest {
        
        let url = try url.appendingQueryItems(parameters: parameters, value: "true")
        return createEmptyRequest(.get, with: url)
    }
}
