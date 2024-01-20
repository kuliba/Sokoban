//
//  FastPaymentsSettingsReducer.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

public final class FastPaymentsSettingsReducer {
    
    private let bankDefaultReduce: BankDefaultReduce
    private let contractReduce: ContractReduce
    private let getProducts: GetProducts
    
    public init(
        bankDefaultReduce: @escaping BankDefaultReduce,
        contractReduce: @escaping ContractReduce,
        getProducts: @escaping GetProducts
    ) {
        self.bankDefaultReduce = bankDefaultReduce
        self.contractReduce = contractReduce
        self.getProducts = getProducts
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
            (state, effect) = update(state, with: products)
            
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
    
    typealias GetProducts = () -> [Product]
    typealias BankDefaultReduce = (State, Event.BankDefault) -> (State, Effect?)
    typealias ContractReduce = (State, Event.Contract) -> (State, Effect?)
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension FastPaymentsSettingsReducer {
    
    func collapseProducts(
        _ state: State
    ) -> State {
        
        guard var details = state.activeDetails,
              details.productSelector.isExpanded
        else { return state }
        
        details.productSelector = details.productSelector.updated(status: .collapsed)
        
        return .init(userPaymentSettings: .contracted(details))
    }
    
    func expandProducts(
        _ state: State
    ) -> State {
        
        guard var details = state.activeDetails,
              !details.productSelector.isExpanded
        else { return state }
        
        details.productSelector = details.productSelector.updated(status: .expanded)
        
        return .init(userPaymentSettings: .contracted(details))
    }
    
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
    
    func selectProduct(
        _ state: State,
        _ product: Product
    ) -> (State, Effect?) {
        
        guard let details = state.activeDetails,
              details.productSelector.isExpanded
        else { return (state, nil) }
        
        let productIDs = getProducts().map(\.id)
        
        guard details.productSelector.selectedProduct?.id != product.id,
              productIDs.contains(product.id)
        else {
            
            var state = state
            state = .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.updated(
                        status: .collapsed
                    )
                ))
            )
            
            return (state, nil)
        }
        
        var state = state
        state.status = .inflight
        
        return (state, .updateProduct(details, product))
    }
    
    func update(
        _ state: State,
        with products: Event.Products
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch products {
        case .collapseProducts:
            state = collapseProducts(state)
            
        case .expandProducts:
            state = expandProducts(state)
            
        case let .selectProduct(product):
            (state, effect) = selectProduct(state, product)
            
        case let .updateProduct(result):
            state = update(state, with: result)
        }
        
        return (state, effect)
    }
    
    func update(
        _ state: State,
        with productUpdate: Event.ProductUpdateResult
    ) -> State {
        
        guard let details = state.activeDetails
        else { return state }
        
        switch productUpdate {
        case let .success(product):
            var details = details
            details.productSelector = details.productSelector.selected(product: product)
            return .init(userPaymentSettings: .contracted(details))
            
        case .failure(.connectivityError):
            var details = details
            details.productSelector = details.productSelector.updated(
                status: .collapsed
            )
            
            return .init(
                userPaymentSettings: .contracted(details),
                status: .connectivityError
            )
            
        case let .failure(.serverError(message)):
            var details = details
            details.productSelector = details.productSelector.updated(
                status: .collapsed
            )
            
            return .init(
                userPaymentSettings: .contracted(details),
                status: .serverError(message)
            )
        }
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
