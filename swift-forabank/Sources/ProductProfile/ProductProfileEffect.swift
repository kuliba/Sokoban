//
//  ProductProfileEffect.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Tagged
import ProductProfileComponents

public enum ProductProfileEffect: Equatable {
    
    case guardCard(ProductProfileComponents.CardGuardianCard)
    case toggleVisibilityOnMain(ProductProfileComponents.CardGuardianProduct)
    case changePin(ProductProfileComponents.CardGuardianCard)
    case showContacts
    case accountOurBank(ProductProfileComponents.TopUpCard)
    case accountAnotherBank(ProductProfileComponents.TopUpCard)
    case accountDetails(ProductProfileComponents.AccountInfoPanelCard)
    case accountStatement(ProductProfileComponents.AccountInfoPanelCard)
    case productDetailsItemlongPress(ProductDetailEvent.ValueForCopy, ProductDetailEvent.TextForInformer)
    case productDetailsIconTap(DocumentItem.ID)
}
