//
//  FastPaymentsSettingsEffect.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import Tagged

enum FastPaymentsSettingsEffect: Equatable {
    
    case activateContract(TargetContract)
    case createContract(ProductID)
    case getSettings
    case prepareSetBankDefault
    case updateProduct(ContractCore)
}

extension FastPaymentsSettingsEffect {
    
#warning("decouple from other types, use own types")
    typealias ProductID = Product.ID
    
    struct TargetContract: Equatable {
        
        let core: ContractCore
        let targetStatus: TargetStatus

        enum TargetStatus: Equatable {
            
            case active, inactive
        }
    }
    
    struct ContractCore: Equatable {
        
        let contractID: ContractID
        let productID: ProductID
        let productType: ProductType
        
        typealias ContractID = Tagged<_ContractID, Int>
        enum _ContractID {}
        
        typealias ProductID = Tagged<_ProductID, Int>
        enum _ProductID {}
        
        enum ProductType {
            
            case account, card
        }
    }
}
