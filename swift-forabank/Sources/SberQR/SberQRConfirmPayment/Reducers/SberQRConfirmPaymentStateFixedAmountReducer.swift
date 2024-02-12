//
//  SberQRConfirmPaymentStateFixedAmountReducer.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

import PaymentComponents

public final class SberQRConfirmPaymentStateFixedAmountReducer {
    
    public typealias State = FixedAmount<GetSberQRDataResponse.Parameter.Info>
    public typealias Event = SberQRConfirmPaymentEvent.FixedAmount

    public typealias ProductSelectReduce = (ProductSelect, ProductSelectEvent) -> ProductSelect
    
    private let productSelectReduce: ProductSelectReduce
    
    public init(
        productSelectReduce: @escaping ProductSelectReduce
    ) {
        self.productSelectReduce = productSelectReduce
    }
}

public extension SberQRConfirmPaymentStateFixedAmountReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        var newState = state
        
        switch event {
        case let .productSelect(productSelectEvent):
            newState.productSelect = productSelectReduce(
                state.productSelect,
                productSelectEvent
            )
        }
        
        return newState
    }
}
