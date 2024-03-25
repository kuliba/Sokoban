//
//  CarouselProduct.swift
//  
//
//  Created by Andryusina Nataly on 24.03.2024.
//

import Foundation

public protocol CarouselProduct {
    
    associatedtype ProductType: Equatable
    associatedtype CardType: Equatable
    
    var type: ProductType { get }
    var cardType: CardType? { get }
}
