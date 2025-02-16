//
//  C2GPaymentReducer.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import PaymentComponents

public final class C2GPaymentReducer<Context> {
    
    private let productSelectReduce: ProductSelectReduce
    
    public init(
        productSelectReduce: @escaping ProductSelectReduce
    ) {
        self.productSelectReduce = productSelectReduce
    }
    
    public typealias ProductSelectReduce = (ProductSelect, ProductSelectEvent) -> ProductSelect
}

public extension C2GPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .productSelect(productSelectEvent):
            state.productSelect = productSelectReduce(state.productSelect, productSelectEvent)
            
        case .termsToggle:
            state.termsCheck.toggle()
        }
        
        return (state, nil)
    }
}

public extension C2GPaymentReducer {
    
    typealias State = C2GPaymentState<Context>
    typealias Event = C2GPaymentEvent
    typealias Effect = C2GPaymentEffect
}
