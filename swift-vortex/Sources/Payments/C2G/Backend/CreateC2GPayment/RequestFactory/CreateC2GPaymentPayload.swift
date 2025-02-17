//
//  CreateC2GPaymentPayload.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import RemoteServices

extension RequestFactory {
    
    public struct CreateC2GPaymentPayload: Equatable {
        
        public let accountID: Int?
        public let cardID: Int?
        public let uin: String
        
        public init(
            accountID: Int?,
            cardID: Int?,
            uin: String
        ) {
            self.accountID = accountID
            self.cardID = cardID
            self.uin = uin
        }
    }
}
