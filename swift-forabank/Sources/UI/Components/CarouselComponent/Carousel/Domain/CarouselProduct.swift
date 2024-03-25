//
//  CarouselProduct.swift
//  
//
//  Created by Andryusina Nataly on 24.03.2024.
//

import Foundation

public protocol CarouselProduct {
    
    associatedtype ProductType
    associatedtype CardType
    
    var type: ProductType { get }
    var cardType: CardType? { get }
}
