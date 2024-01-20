//
//  FastPaymentsSettingsReducer.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

public final class FastPaymentsSettingsReducer {
    
    private let bankDefaultReduce: BankDefaultReduce
    private let contractReduce: ContractReduce
    private let productsReduce: ProductsReduce
    
    public init(
        bankDefaultReduce: @escaping BankDefaultReduce,
        contractReduce: @escaping ContractReduce,
        productsReduce: @escaping ProductsReduce
    ) {
        self.bankDefaultReduce = bankDefaultReduce
        self.contractReduce = contractReduce
        self.productsReduce = productsReduce
    }
}

public extension FastPaymentsSettingsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .bankDefault(bankDefault):
            (state, effect) = bankDefaultReduce(state, bankDefault)
            
        case let .contract(contract):
            (state, effect) = contractReduce(state, contract)
            
        case let .products(products):
            (state, effect) = productsReduce(state, products)
            
        case .appear:
            (state, effect) = handleAppear(state)
            
        case let .loadSettings(settings):
            state = handleLoadedSettings(settings)
            
        case .resetStatus:
            state = resetStatus(state)
        }
        
        return (state, effect)
    }
}

public extension FastPaymentsSettingsReducer {
    
    typealias BankDefaultReduce = (State, Event.BankDefault) -> (State, Effect?)
    typealias ContractReduce = (State, Event.Contract) -> (State, Effect?)
    typealias ProductsReduce = (State, Event.Products) -> (State, Effect?)
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension FastPaymentsSettingsReducer {
    
    func handleAppear(
        _ state: State
    ) -> (State, Effect) {
        
        var state = state
        state.status = .inflight
        
        return (state, .getSettings)
    }
    
    func handleLoadedSettings(
        _ userPaymentSettings: UserPaymentSettings
    ) -> State {
        
        .init(userPaymentSettings: userPaymentSettings)
    }
    
    func resetStatus(
        _ state: State
    ) -> State {
        
        var state = state
        state.status = nil
        
        return state
    }
}

// MARK: - Helpers

private extension UserPaymentSettings.ProductSelector {
    
    var isExpanded: Bool { status == .expanded }
}

private extension FastPaymentsSettingsEffect {
    
    static func updateProduct(
        _ details: UserPaymentSettings.ContractDetails,
        _ product: Product
    ) -> Self {
        
        .updateProduct(.init(
            contractID: .init(details.paymentContract.id.rawValue),
            product: product
        ))
    }
}

private extension FastPaymentsSettingsState {
    
    var activeDetails: UserPaymentSettings.ContractDetails? {
        
        guard case let .contracted(details) = userPaymentSettings,
              details.isActive
        else { return nil }
        
        return details
    }
}

private extension UserPaymentSettings.ContractDetails {
    
    var isActive: Bool {
        
        paymentContract.contractStatus == .active
    }
}
