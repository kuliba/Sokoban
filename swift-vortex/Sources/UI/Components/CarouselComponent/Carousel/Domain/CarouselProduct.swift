//
//  CarouselProduct.swift
//  
//
//  Created by Andryusina Nataly on 24.03.2024.
//

import Foundation

public protocol CarouselProduct {
        
    var productType: ProductType { get }
    var isAdditional: Bool { get }
}
