//
//  SberQRConfirmPaymentStateEditableAmountReducer.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

public final class SberQRConfirmPaymentStateEditableAmountReducer {
    
    public typealias State = SberQRConfirmPaymentState.EditableAmount
    public typealias Event = SberQRConfirmPaymentEvent.EditableAmountEvent
    
    public typealias GetProducts = () -> [ProductSelect.Product]
    public typealias Pay = () -> Void
    
    private let getProducts: GetProducts
    private let pay: Pay
    
    public init(
        getProducts: @escaping GetProducts,
        pay: @escaping Pay
    ) {
        self.getProducts = getProducts
        self.pay = pay
    }
    
    public func reduce(
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
            pay()
            
        case let .select(id):
            guard let product = getProducts().first(where: { $0.id == id })
            else { break }
            
            newState.productSelect = .compact(product)
            
        case .toggleProductSelect:
            switch state.productSelect {
            case let .compact(product):
                newState.productSelect = .expanded(product, getProducts())
                
            case let .expanded(selected, _):
                newState.productSelect = .compact(selected)
            }
        }
        
        return newState
    }
}

