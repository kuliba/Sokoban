//
//  RequestFactory+createFastPaymentContractFindListRequest.swift
//
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createFastPaymentContractFindListRequest(
        url: URL
    ) -> URLRequest {
        
        createEmptyRequest(.get, with: url)
    }
}
