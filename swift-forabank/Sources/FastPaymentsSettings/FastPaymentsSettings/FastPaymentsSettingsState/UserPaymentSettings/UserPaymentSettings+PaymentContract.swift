//
//  UserPaymentSettings+PaymentContract.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

import Tagged

public extension UserPaymentSettings {
    
    struct PaymentContract: Equatable, Identifiable {
        
        public let id: ID
        public let accountID: Product.AccountID
        public let contractStatus: ContractStatus
        public let phoneNumber: PhoneNumber
        public let phoneNumberMasked: PhoneNumberMask
        
        public init(
            id: ID,
            accountID: Product.AccountID,
            contractStatus: ContractStatus,
            phoneNumber: PhoneNumber,
            phoneNumberMasked: PhoneNumberMask
        ) {
            self.id = id
            self.accountID = accountID
            self.contractStatus = contractStatus
            self.phoneNumber = phoneNumber
            self.phoneNumberMasked = phoneNumberMasked
        }
        
        public typealias ID = Tagged<_ID, Int>
        public enum _ID {}
        
        public enum ContractStatus: Equatable {
            
            case active, inactive
        }
    }
}
