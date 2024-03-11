//
//  UtilityPaymentFlowState.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import ForaTools

public struct UtilityPaymentFlowState<LastPayment, Operator> {
    
    public var isInflight: Bool
    
    private var stack: NonEmptyStack<Flow>
    
    public init(
        initialFlow: Flow,
        isInflight: Bool = false
    ) {
        self.stack = .init(initialFlow)
        self.isInflight = isInflight
    }
}

public extension UtilityPaymentFlowState {

    var current: Flow {
        
        get { stack.top }
        set { stack.top = newValue }
    }
}

public extension UtilityPaymentFlowState {
    
    typealias Flow = UtilityPaymentFlow<LastPayment, Operator>
}

extension UtilityPaymentFlowState: Equatable where LastPayment: Equatable, Operator: Equatable {}
