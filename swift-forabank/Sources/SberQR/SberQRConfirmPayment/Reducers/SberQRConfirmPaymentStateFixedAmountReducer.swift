//
//  SberQRConfirmPaymentStateFixedAmountReducer.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

public final class SberQRConfirmPaymentStateFixedAmountReducer {
    
    public typealias State = SberQRConfirmPaymentState.FixedAmount
    public typealias Event = SberQRConfirmPaymentEvent.FixedAmount
    public typealias ProductSelectReduce = (ProductSelect, SberQRConfirmPaymentEvent.ProductSelectEvent) -> ProductSelect

    public typealias Pay = (State) -> Void
    
    private let productSelectReduce: ProductSelectReduce
    private let pay: Pay
    
    public init(
        productSelectReduce: @escaping ProductSelectReduce,
        pay: @escaping Pay
    ) {
        self.productSelectReduce = productSelectReduce
        self.pay = pay
    }
}

public extension SberQRConfirmPaymentStateFixedAmountReducer {

    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        var newState = state
        
        switch event {
        case .pay:
            pay(state)
            
        case let .productSelect(productSelectEvent):
            newState.productSelect = productSelectReduce(
                state.productSelect,
                productSelectEvent
            )
        }
        
        return newState
    }
}
