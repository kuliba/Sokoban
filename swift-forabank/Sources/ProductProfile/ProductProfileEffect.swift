//
//  ProductProfileEffect.swift
//  
//
//  Created by Andryusina Nataly on 13.02.2024.
//

public enum ProductProfileEffect: Equatable {
    
    case blockCard(Card)
    case unblockCard(Card)
    case showOnMain(Product)
    case hideFromMain(Product)
    case changePin
}
