//
//  SberQRConfirmPaymentStateEditableAmountReducer.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

public final class SberQRConfirmPaymentStateEditableAmountReducer {
    
    public typealias State = SberQRConfirmPaymentState.EditableAmount
    public typealias Event = SberQRConfirmPaymentEvent.EditableAmount
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

public extension SberQRConfirmPaymentStateEditableAmountReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        var newState = state
        
        switch event {
        case let .editAmount(amount):
            newState.bottom = .init(
                id: state.bottom.id,
                value: amount,
                title: state.bottom.title,
                validationRules: state.bottom.validationRules,
                button: state.bottom.button
            )
            
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
