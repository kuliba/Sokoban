//
//  ProductsReducer.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

#warning("add tests")
public final class ProductsReducer {
    
    private let getProducts: GetProducts
    
    public init(getProducts: @escaping GetProducts) {
        
        self.getProducts = getProducts
    }
}

public extension ProductsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
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
}

public extension ProductsReducer {
    
    typealias GetProducts = () -> [Product]
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent.Products
    typealias Effect = FastPaymentsSettingsEffect
}

private extension ProductsReducer {
    
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
        with productUpdate: FastPaymentsSettingsEvent.ProductUpdateResult
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

private extension UserPaymentSettings.ProductSelector {
    
    var isExpanded: Bool { status == .expanded }
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
