//
//  GlobalReducer+ext.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Foundation
import RxViewModel

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
    
    static func reduceForPreview() -> RxViewModel<GlobalState, GlobalEvent, GlobalEffect>.Reduce {
        
        GlobalReducer.preview(maxOffsetX: .maxOffsetX).reduce(_:_:)
    }
}

public extension CGFloat {
    
    static let maxOffsetX = SliderConfig.default.maxOffsetX
}
