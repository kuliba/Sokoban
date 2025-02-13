//
//  ResponseMapper+GetServiceCategoryListResponse.swift
//
//
//  Created by Igor Malyarov on 13.08.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public typealias GetServiceCategoryListResponse = SerialStamped<String, ServiceCategory>
}

extension ResponseMapper {
    
    public struct ServiceCategory: Equatable {
        
        public let latestPaymentsCategory: LatestPaymentsCategory?
        public let md5Hash: String
        public let name: String
        public let ord: Int
        public let paymentFlow: PaymentFlow
        public let hasSearch: Bool
        public let type: CategoryType
        
        public init(
            latestPaymentsCategory: LatestPaymentsCategory?,
            md5Hash: String,
            name: String,
            ord: Int,
            paymentFlow: PaymentFlow,
            hasSearch: Bool,
            type: CategoryType
        ) {
            self.latestPaymentsCategory = latestPaymentsCategory
            self.md5Hash = md5Hash
            self.name = name
            self.ord = ord
            self.paymentFlow = paymentFlow
            self.hasSearch = hasSearch
            self.type = type
        }
        
        public typealias CategoryType = String
        public typealias LatestPaymentsCategory = String
        public typealias PaymentFlow = String        
    }
}
