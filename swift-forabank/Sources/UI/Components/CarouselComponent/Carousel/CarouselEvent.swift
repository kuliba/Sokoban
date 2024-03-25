//
//  CarouselEvent.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import Foundation

public enum CarouselEvent: Equatable {
    
    case toggle(
        id: ProductType,
        screenwidth: CGFloat,
        xOffset: CGFloat
    )
    case scrolledTo(ProductType)
    case select(ProductType, delay: TimeInterval = 0.2)
    case didScrollTo(CGFloat)
    case update([Product])
    case closeSticker
}
