//
//  CarouselEvent.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import Foundation

public enum CarouselEvent: Equatable {
    
    case toggle(
        id: ProductGroup.ID,
        screenwidth: CGFloat,
        xOffset: CGFloat
    )
    case scrolledTo(ProductGroup.ID)
    case select(ProductGroup.ID, delay: TimeInterval = 0.2)
    case didScrollTo(CGFloat)
    case update([Product], sticker: Product?)
}
