//
//  FastPaymentsSettingsEffect.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import Tagged

public enum FastPaymentsSettingsEffect: Equatable {
    
    case contract(Contract)
    case getSettings
    case prepareSetBankDefault
    case updateProduct(ContractCore)
}

public extension FastPaymentsSettingsEffect {
    
    enum Contract: Equatable {
        
        case activateContract(TargetContract)
        case createContract(ProductID)
        case deactivateContract(TargetContract)
    }
}

public extension FastPaymentsSettingsEffect.Contract {
    
    typealias ProductID = Tagged<_ProductID, Int>
    enum _ProductID {}
    
    struct TargetContract: Equatable {
        
        public let core: ContractCore
        public let targetStatus: TargetStatus
        
        public init(
            core: ContractCore, 
            targetStatus: TargetStatus
        ) {
            self.core = core
            self.targetStatus = targetStatus
        }
        
        public enum TargetStatus: Equatable {
            
            case active, inactive
        }
    }
    
    typealias ContractCore = FastPaymentsSettingsEffect.ContractCore
}

public extension FastPaymentsSettingsEffect {
    
    struct ContractCore: Equatable {
        
        public let contractID: ContractID
        public let product: Product
        
        public init(contractID: ContractID, product: Product) {
            
            self.contractID = contractID
            self.product = product
        }
        
        public typealias ContractID = Tagged<_ContractID, Int>
        public enum _ContractID {}
    }
}
