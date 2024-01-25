//
//  FastPaymentsSettingsEffect.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import Tagged

public enum FastPaymentsSettingsEffect: Equatable {
    
    case consentList(ConsentListEffect)
    case contract(ContractEffect)
    case getSettings
    case prepareSetBankDefault
    case subscription(SubscriptionEffect)
    case updateProduct(ContractCore)
}

public extension FastPaymentsSettingsEffect {
    
    struct ContractCore: Equatable {
        
        public let contractID: ContractID
        public let productID: Product.ID
        
        public init(
            contractID: ContractID,
            productID: Product.ID
        ) {
            self.contractID = contractID
            self.productID = productID
        }
        
        public typealias ContractID = Tagged<_ContractID, Int>
        public enum _ContractID {}
    }
}
