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
    case sendAll
    case sendSelect
    case close
    case hideCheckbox
    case closeModal
}

public enum ProductDetailsStatus: Equatable {
    
    case appear
    case itemTapped(ProductDetailEvent)
    case sendAll
    case sendSelect
    case close
    case closeModal
}
