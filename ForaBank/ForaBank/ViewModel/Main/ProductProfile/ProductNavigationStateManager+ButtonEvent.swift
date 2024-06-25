//
//  ProductNavigationStateManager+ButtonEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.04.2024.
//

import Tagged

extension ProductProfileFlowManager {
    
    struct ButtonEvent {
        
        let productID: ProductData.ID
        let type: ButtonEventType
    }
    
    enum ButtonEventType {
        
        case accountDetails
        case accountStatement
        case accountOurBank
        case accountAnotherBank
        case cardGuardian
        case changePin
        case visibility
    }
}
