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
    case deactivateContract(TargetContract)
    case getSettings
    case prepareSetBankDefault
    case updateProduct(ContractCore)
}

extension FastPaymentsSettingsEffect {
    
    typealias ProductID = Tagged<_ProductID, Int>
    enum _ProductID {}
    
    struct TargetContract: Equatable {
        
        let core: ContractCore
        let targetStatus: TargetStatus
        
        enum TargetStatus: Equatable {
            
            case active, inactive
        }
    }
    
    struct ContractCore: Equatable {
        
        let contractID: ContractID
        let product: Product
        
        typealias ContractID = Tagged<_ContractID, Int>
        enum _ContractID {}
    }
}
