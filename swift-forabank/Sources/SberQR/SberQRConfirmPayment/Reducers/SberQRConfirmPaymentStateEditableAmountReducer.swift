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
    
    private let productSelectReduce: ProductSelectReduce
    
    public init(
        productSelectReduce: @escaping ProductSelectReduce
    ) {
        self.productSelectReduce = productSelectReduce
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
            
        case let .productSelect(productSelectEvent):
            newState.productSelect = productSelectReduce(
                state.productSelect,
                productSelectEvent
            )
        }
        
        return newState
    }
}
