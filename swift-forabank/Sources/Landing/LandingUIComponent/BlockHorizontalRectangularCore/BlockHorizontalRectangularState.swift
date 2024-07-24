//
//  BlockHorizontalRectangularState.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation

public struct BlockHorizontalRectangularState: Equatable {
    
    let block: UILanding.BlockHorizontalRectangular
    var inputStates: [InputState] = []
    var newValues: [BlockHorizontalRectangularEvent.Limit] = []
    
    public init(
        block: UILanding.BlockHorizontalRectangular
    ) {
        self.block = block
        block.list.forEach {
            $0.limits.forEach {
                inputStates.append(.init(id: $0.id, maxSum: $0.maxSum, value: ""))
            }
        }
    }
}
