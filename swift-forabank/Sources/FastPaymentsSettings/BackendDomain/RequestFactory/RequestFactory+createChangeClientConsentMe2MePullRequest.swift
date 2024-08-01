//
//  RequestFactory+createChangeClientConsentMe2MePullRequest.swift
//
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation
import RemoteServices
import Tagged

public extension RequestFactory {
    
    typealias BankIDList = [BankID]
    typealias BankID = Tagged<_BankID, String>
    enum _BankID {}
    
    static func createChangeClientConsentMe2MePullRequest(
        url: URL,
        payload: BankIDList
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension RequestFactory.BankIDList {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "bankIdList": map(\.rawValue)
            ] as [String: [String]])
        }
    }
}
