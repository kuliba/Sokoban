//
//  ContractEffect.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

import Tagged

public enum ContractEffect: Equatable {
    
    case activateContract(TargetContract)
    case createContract(ProductID)
    case deactivateContract(TargetContract)
}

public extension ContractEffect {
    
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
    
    typealias ProductID = Tagged<_ProductID, Int>
    enum _ProductID {}
}
