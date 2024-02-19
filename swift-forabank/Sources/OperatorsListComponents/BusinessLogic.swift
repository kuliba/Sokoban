//
//  BusinessLogic.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2024.
//

import Foundation

final public class BusinessLogic {
    
    let latestPayments: () -> [LatestPayment]
    let operators: () -> [Operator]
    
    init(
        latestPayments: @escaping () -> [LatestPayment],
        operators: @escaping () -> [Operator]
    ) {
        self.latestPayments = latestPayments
        self.operators = operators
    }
}

public extension BusinessLogic {

    func process(
        event: ComposedOperatorsEvent,
        completion: @escaping () -> Void
    ) {
        
        switch event {
        case let .selectLastOperation(id):
            break
        case let .selectOperator(id):
            break
        case let .didScroll(`operator`):
            break
        }
    }
}
