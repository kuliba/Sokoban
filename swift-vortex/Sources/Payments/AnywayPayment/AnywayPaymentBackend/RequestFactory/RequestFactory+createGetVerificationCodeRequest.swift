//
//  RequestFactory+createGetVerificationCodeRequest.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import Foundation
import RemoteServices
import Tagged

public extension RequestFactory {
    
    static func createGetVerificationCodeRequest(
        url: URL
    ) throws -> URLRequest {
        
        return createEmptyRequest(.get, with: url)
    }
}
