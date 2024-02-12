//
//  BusinessLogic.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2024.
//

import Foundation

import Combine
import GenericRemoteService

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
        event: Event,
        completion: @escaping () -> Void
    ) {
        
        switch event {
        case .optionSelect(let operatorViewModel):
            break
        }
    }
}
