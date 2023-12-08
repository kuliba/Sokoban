//
//  SberQRConfirmPaymentStateFixedAmountReducer.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

public final class SberQRConfirmPaymentStateFixedAmountReducer {
    
    public typealias State = SberQRConfirmPaymentState.FixedAmount
    public typealias Event = SberQRConfirmPaymentEvent.FixedAmount
    
    public typealias GetProducts = () -> [ProductSelect.Product]
    public typealias Pay = (State) -> Void
    
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
        case .pay:
            pay(state)
            
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
