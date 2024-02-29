//
//  CardActivateReducer+ext.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Foundation
import RxViewModel

public extension CardActivateReducer {
    
    static func preview(
        maxOffsetX: CGFloat
    ) -> CardActivateReducer {
        
        .init(
            cardReduce: CardReducer().reduce,
            sliderReduce: SliderReducer(
                maxOffsetX: SliderConfig.default.maxOffsetX
            ).reduce,
            maxOffset: SliderConfig.default.maxOffsetX
        )
    }
    
    static func reduceForPreview() -> RxViewModel<CardActivateState, CardActivateEvent, CardActivateEffect>.Reduce {
        
        CardActivateReducer.preview(maxOffsetX: .maxOffsetX).reduce(_:_:)
    }
}

public extension CGFloat {
    
    static let maxOffsetX = SliderConfig.default.maxOffsetX
}
