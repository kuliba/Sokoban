//
//  UserPaymentSettings+PaymentContract.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

import Tagged

public extension UserPaymentSettings {
    
    struct PaymentContract: Equatable, Identifiable {
        
        public let id: ContractID
        public let productID: Product.ID
        public let contractStatus: ContractStatus
        public let phoneNumber: PhoneNumber
        public let phoneNumberMasked: String
        
        public init(
            id: ContractID,
            productID: Product.ID,
            contractStatus: ContractStatus,
            phoneNumber: PhoneNumber,
            phoneNumberMasked: String
        ) {
            self.id = id
            self.productID = productID
            self.contractStatus = contractStatus
            self.phoneNumber = phoneNumber
            self.phoneNumberMasked = phoneNumberMasked
        }
        
        public typealias ContractID = Tagged<_ContractID, Int>
        public enum _ContractID {}
        
        public enum ContractStatus: Equatable {
            
            case active, inactive
        }
    }
}
