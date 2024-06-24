//
//  BlockHorizontalRectangularState.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation
import SwiftUI

public struct BlockHorizontalRectangularState: Equatable {
    
    let block: UILanding.BlockHorizontalRectangular
    var inputStates: [InputState] = []
    var event: BlockHorizontalRectangularEvent?
    
    public init(
        block: UILanding.BlockHorizontalRectangular,
        event: BlockHorizontalRectangularEvent? = nil
    ) {
        self.block = block
        self.event = event
        block.list.forEach {
            $0.limits.forEach {
                inputStates.append(.init(id: $0.id, maxSum: $0.maxSum, value: ""))
            }
        }
    }
}
