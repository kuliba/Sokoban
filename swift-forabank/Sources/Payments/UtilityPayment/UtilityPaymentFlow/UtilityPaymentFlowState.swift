//
//  UtilityPaymentFlowState.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import ForaTools

public struct UtilityPaymentFlowState<LastPayment, Operator, Service> {
    
    public var status: Status?
    
    private var stack: Stack<Flow>
    
    public init(
        _ flows: [Flow],
        status: Status? = nil
    ) {
        self.stack = .init(flows)
        self.status = status
    }
}

public extension UtilityPaymentFlowState {

    var current: Flow? {
        
        get { stack.top }
        set { stack.top = newValue }
    }
    
    var isInflight: Bool {
        
        get { status == .inflight }
        set { if newValue { status = .inflight }}
    }
    
    mutating func push(_ flow: Flow) {
        
        stack.push(flow)
    }
}

public extension UtilityPaymentFlowState {
    
    enum Status: Equatable {
        
        #warning("drop `inflight` case - leave effect handling to client")
        case inflight
        case failure(ServiceFailure)
    }
    
    typealias Flow = UtilityPaymentFlow<LastPayment, Operator, Service>
}

extension UtilityPaymentFlowState: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
