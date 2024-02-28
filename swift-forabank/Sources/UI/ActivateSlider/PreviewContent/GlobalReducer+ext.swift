//
//  GlobalReducer+ext.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Foundation

public extension GlobalReducer {
    
    static func preview(
        maxOffsetX: CGFloat
    ) -> GlobalReducer {
        
        .init(
            cardReduce: CardReducer().reduce,
            sliderReduce: SliderReducer(
                maxOffsetX: SliderConfig.default.maxOffsetX
            ).reduce,
            maxOffset: SliderConfig.default.maxOffsetX
        )
    }
}

public extension CGFloat {
    
    static let maxOffsetX = SliderConfig.default.maxOffsetX
}
