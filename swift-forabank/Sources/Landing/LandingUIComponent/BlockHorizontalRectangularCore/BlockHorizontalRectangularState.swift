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
    let limitType: String
    
    public init(
        block: UILanding.BlockHorizontalRectangular,
        initialLimitsInfo: CardLimitsInfo?
    ) {
        self.block = block
        self.limitType = initialLimitsInfo?.type ?? ""
        inputStates = initialLimitsInfo?.svCardLimits?.inputStates(maxValues: block.maxValues) ?? []
    }
}

private extension UILanding.BlockHorizontalRectangular {
    
    var maxValues: [String: Decimal] {
        
        var values: [String: Decimal] = [:]
        
        list.forEach {
            $0.limits.forEach {
                values[$0.id] = $0.maxSum
            }
        }
        return values
    }
}

private extension SVCardLimits {
    
    func inputStates(maxValues: [String: Decimal]) -> [InputState] {
        
        var initialValues: [InputState] = []
        
        limitsList.forEach {
            $0.limits.forEach { limit in
                initialValues.append(.init(
                    id: limit.name,
                    maxSum: maxValues[limit.name] ?? 0,
                    value: limit.value
                )
                )
            }
        }
        
        return initialValues
    }
}
