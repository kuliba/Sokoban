//
//  CarouselProduct.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 25.03.2024.
//

import Foundation
import CarouselComponent

struct CarouselProduct: CarouselComponent.CarouselProduct, Equatable, Identifiable {
    
    let id: Int
    let productType: ProductType
    let isAdditional: Bool
}
