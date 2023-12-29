//
//  RequestFactory+createPrepareSetBankDefaultRequest.swift
//
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation

public extension RequestFactory {
    
    static func createPrepareSetBankDefaultRequest(
        url: URL
    ) -> URLRequest {
        
        createEmptyRequest(.post, with: url)
    }
}
