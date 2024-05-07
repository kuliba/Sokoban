//
//  CardActivateReducer+ext.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Foundation
import RxViewModel

public extension CardActivateReducer {
    
    static func `default`(
        maxOffsetX: CGFloat
    ) -> CardActivateReducer {
        
        .init(
            cardReduce: CardReducer().reduce,
            sliderReduce: SliderReducer(maxOffsetX: maxOffsetX).reduce,
            maxOffset: maxOffsetX
        )
    }
    
    static func reduceForPreview() -> RxViewModel<CardActivateState, CardActivateEvent, CardActivateEffect>.Reduce {
        
        CardActivateReducer.default(maxOffsetX: .maxOffsetX).reduce(_:_:)
    }
}

public extension CGFloat {
    
    static let maxOffsetX = SliderConfig.default.maxOffsetX
}
