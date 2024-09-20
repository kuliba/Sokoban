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
        public let search: Bool
        public let type: CategoryType
        
        public init(
            latestPaymentsCategory: LatestPaymentsCategory?,
            md5Hash: String,
            name: String,
            ord: Int,
            paymentFlow: PaymentFlow,
            search: Bool,
            type: CategoryType
        ) {
            self.latestPaymentsCategory = latestPaymentsCategory
            self.md5Hash = md5Hash
            self.name = name
            self.ord = ord
            self.paymentFlow = paymentFlow
            self.search = search
            self.type = type
        }
        
        public enum CategoryType: Equatable {
            
            case charity
            case digitalWallets
            case education
            case housingAndCommunalService
            case internet
            case mobile
            case networkMarketing
            case qr
            case repaymentLoansAndAccounts
            case security
            case socialAndGames
            case taxAndStateService
            case transport
        }
        
        public enum LatestPaymentsCategory: Equatable {
            
            case charity
            case digitalWallets
            case education
            case internet
            case mobile
            case networkMarketing
            case repaymentLoansAndAccounts
            case security
            case service
            case socialAndGames
            case taxAndStateService
            case transport
        }
        
        public enum PaymentFlow: Equatable {
            
            case mobile
            case qr
            case standard
            case taxAndStateServices
            case transport
        }
    }
}
