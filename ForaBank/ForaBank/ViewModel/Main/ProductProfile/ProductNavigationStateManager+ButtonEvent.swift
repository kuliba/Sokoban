//
//  ProductNavigationStateManager+ButtonEvent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.04.2024.
//

import Tagged

extension ProductNavigationStateManager {
    
    enum ButtonEvent {
        
        case accountDetails(ProductData.ID)
        case accountStatement(ProductData.ID)
    }
}
