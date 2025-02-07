//
//  RequestFactory+createCardApplication.swift
//  
//
//  Created by Дмитрий Савушкин on 27.01.2025.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createCardApplication(
        url: URL,
        payload: CreateCardApplicationPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

public struct CreateCardApplicationPayload: Equatable {
    
    let requestId: String
    let cardApplicationCardType: String
    let cardProductExtId: Int
    let cardProductName: String
    let smsInfo: Bool
    let verificationCode: String
    
    public init(
        requestId: String,
        cardApplicationCardType: String,
        cardProductExtId: Int,
        cardProductName: String,
        smsInfo: Bool,
        verificationCode: String
    ) {
        self.requestId = requestId
        self.cardApplicationCardType = cardApplicationCardType
        self.cardProductExtId = cardProductExtId
        self.cardProductName = cardProductName
        self.smsInfo = smsInfo
        self.verificationCode = verificationCode
    }
}

private extension CreateCardApplicationPayload {
    
    var httpBody: Data {
        
        get throws {
            
            return try JSONSerialization.data(withJSONObject: [
                "requestId" : requestId,
                "cardApplicationCardType" : cardApplicationCardType,
                "cardProductExtId" : cardProductExtId,
                "cardProductName" : cardProductName,
                "smsInfo" : smsInfo,
                "verificationCode" : verificationCode
            ] as [String: Any])
        }
    }
}
