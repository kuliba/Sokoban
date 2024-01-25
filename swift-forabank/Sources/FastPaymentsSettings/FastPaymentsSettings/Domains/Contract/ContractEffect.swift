//
//  ContractEffect.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

import Tagged

public extension FastPaymentsSettingsEffect {
    
    enum ContractEffect: Equatable {
        
        case activateContract(TargetContract)
        case createContract(ProductID)
        case deactivateContract(TargetContract)
    }
}

public extension FastPaymentsSettingsEffect.ContractEffect {
    
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
