//
//  RequestFactory+createPrepareOpenSavingsAccountRequest.swift
//
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createPrepareOpenSavingsAccountRequest(
        url: URL
    ) -> URLRequest {
        
        createEmptyRequest(.post, with: url)
    }
}
