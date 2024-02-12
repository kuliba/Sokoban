//
//  SberQRConfirmPaymentStateEditableAmountReducer.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation
import PaymentComponents

public final class SberQRConfirmPaymentStateEditableAmountReducer {
    
    public typealias State = EditableAmount<GetSberQRDataResponse.Parameter.Info>
    public typealias Event = SberQRConfirmPaymentEvent.EditableAmount
    
    public typealias ProductSelectReduce = (ProductSelect, ProductSelectEvent) -> ProductSelect
    
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
        case let .editAmount(value):
            let isEnabled = state.productSelect.canPay(value)
            newState.amount = .init(
                title: state.amount.title,
                value: value,
                button: .init(
                    title: state.amount.button.title,
                    isEnabled: isEnabled
                )
            )
            
        case let .productSelect(productSelectEvent):
            newState.productSelect = productSelectReduce(
                state.productSelect,
                productSelectEvent
            )
            newState.amount.button.isEnabled = newState.productSelect.canPay(newState.amount.value)
        }
        
        return newState
    }
}

private extension ProductSelect {
    
    func canPay(_ amount: Decimal) -> Bool {
        
        guard let balance = selected?.balance
        else { return false }
        
        return 0 < amount && amount <= balance
    }
}
