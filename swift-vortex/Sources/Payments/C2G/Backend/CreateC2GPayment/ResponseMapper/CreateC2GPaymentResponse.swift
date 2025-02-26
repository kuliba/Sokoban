//
//  CreateC2GPaymentResponse.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public struct CreateC2GPaymentResponse: Equatable {
        
        public let amount: Decimal?
        public let dateForDetail: String
        public let documentStatus: String
        public let merchantName: String?
        public let message: String?
        public let paymentOperationDetailID: Int
        public let purpose: String?
        
        public init(
            amount: Decimal?,
            dateForDetail: String,
            documentStatus: String,
            merchantName: String?,
            message: String?,
            paymentOperationDetailID: Int,
            purpose: String?
        ) {
            self.amount = amount
            self.dateForDetail = dateForDetail
            self.documentStatus = documentStatus
            self.merchantName = merchantName
            self.message = message
            self.paymentOperationDetailID = paymentOperationDetailID
            self.purpose = purpose
        }
    }
}
