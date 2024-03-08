//
//  UtilityPaymentFlowState.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import ForaTools

public struct UtilityPaymentFlowState<LastPayment, Operator> {
    
    private var stack: NonEmptyStack<Flow>
    
    public init(initialFlow: Flow) {
        
        self.stack = .init(initialFlow)
    }
}

public extension UtilityPaymentFlowState {

    var current: Flow {
        
        get { stack.last }
        set { stack.last = newValue }
    }
}

public extension UtilityPaymentFlowState {
    
    typealias Flow = UtilityPaymentFlow<LastPayment, Operator>
}

extension UtilityPaymentFlowState: Equatable where LastPayment: Equatable, Operator: Equatable {}
