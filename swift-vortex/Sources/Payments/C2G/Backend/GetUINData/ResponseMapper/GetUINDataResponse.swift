//
//  GetUINDataResponse.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public struct GetUINDataResponse: Equatable {
        
        public let termsCheck: Bool
        public let transAmm: Decimal?
        public let purpose: String?
        public let merchantName: String?
        public let dateN: String?
        public let legalAct: String?
        public let paymentTerm: String?
        public let discountFixedValue: Decimal?
        public let discountExpiry: String?
        public let discountSizeValue: Decimal?
        public let multiplierSizeValue: Decimal?
        public let payerName: String?
        public let payerINN: String?
        public let payerKPP: String?
        public let url: String
        public let uin: String
        
        public init(
            termsCheck: Bool,
            transAmm: Decimal?,
            purpose: String?,
            merchantName: String?,
            dateN: String?,
            legalAct: String?,
            paymentTerm: String?,
            discountFixedValue: Decimal?,
            discountExpiry: String?,
            discountSizeValue: Decimal?,
            multiplierSizeValue: Decimal?,
            payerName: String?,
            payerINN: String?,
            payerKPP: String?,
            url: String,
            uin: String
        ) {
            self.termsCheck = termsCheck
            self.transAmm = transAmm
            self.purpose = purpose
            self.merchantName = merchantName
            self.dateN = dateN
            self.legalAct = legalAct
            self.paymentTerm = paymentTerm
            self.discountFixedValue = discountFixedValue
            self.discountExpiry = discountExpiry
            self.discountSizeValue = discountSizeValue
            self.multiplierSizeValue = multiplierSizeValue
            self.payerName = payerName
            self.payerINN = payerINN
            self.payerKPP = payerKPP
            self.url = url
            self.uin = uin
        }
    }
}
