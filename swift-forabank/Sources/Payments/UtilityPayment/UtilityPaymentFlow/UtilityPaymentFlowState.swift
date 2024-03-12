//
//  UtilityPaymentFlowState.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import ForaTools

public struct UtilityPaymentFlowState<LastPayment, Operator, Service> {
    
    public var isInflight: Bool
    
    private var stack: Stack<Flow>
    
    public init(
        _ flows: [Flow],
        isInflight: Bool = false
    ) {
        self.stack = .init(flows)
        self.isInflight = isInflight
    }
}

public extension UtilityPaymentFlowState {

    var current: Flow? {
        
        get { stack.top }
        set { stack.top = newValue }
    }
    
    mutating func push(_ flow: Flow) {
        
        stack.push(flow)
    }
}

public extension UtilityPaymentFlowState {
    
    typealias Flow = UtilityPaymentFlow<LastPayment, Operator, Service>
}

extension UtilityPaymentFlowState: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
