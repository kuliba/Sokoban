//
//  ProductDetailsEvent.swift
//  
//
//  Created by Andryusina Nataly on 07.03.2024.
//

import Tagged

public enum ProductDetailsEvent: Equatable {
    
    case appear
    case itemTapped(ProductDetailEvent)
    case share
    case sendAll
    case sendSelect
}
