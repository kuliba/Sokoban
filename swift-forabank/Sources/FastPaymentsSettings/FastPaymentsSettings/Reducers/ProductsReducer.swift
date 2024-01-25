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
        case let .selectProduct(productID):
            (state, effect) = selectProduct(state, productID)
            
        case .toggleProducts:
            state = toggleProducts(state)
            
        case let .updateProduct(result):
            state = update(state, with: result)
        }
        
        return (state, effect)
    }
}

public extension ProductsReducer {
    
    typealias GetProducts = () -> [Product]
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent.ProductsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension UserPaymentSettings.ProductSelector {
    
    func isSelected(_ productID: Product.ID) -> Bool {
        
        selectedProduct?.id == productID
    }
}

private extension ProductsReducer {
    
    func canSelect(_ productID: Product.ID) -> Bool {
        
        let productIDs = getProducts().map(\.id)
        return productIDs.contains(productID)
    }
    
    func product(forID id: Product.ID) -> Product? {
        
        getProducts().first(where: { $0.id == id })
    }
    
    func selectProduct(
        _ state: State,
        _ productID: Product.ID
    ) -> (State, Effect?) {
        
        guard let details = state.activeDetails,
              details.productSelector.isExpanded
        else { return (state, nil) }
        
        guard !details.productSelector.isSelected(productID),
              canSelect(productID)
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
        
        return (state, .updateProduct(details, productID))
    }
    
    func toggleProducts(
        _ state: State
    ) -> State {
        
        guard let details = state.activeDetails
        else { return state }
        
        var state = state
        
        switch details.productSelector.status {
        case .collapsed:
            state = .init(
                userPaymentSettings: .contracted(
                    details.updated(
                        productSelector: details.productSelector.updated(
                            status: .expanded
                        )
                    )
                )
            )
            
        case .expanded:
            state = .init(
                userPaymentSettings: .contracted(
                    details.updated(
                        productSelector: details.productSelector.updated(
                            status: .collapsed
                        )
                    )
                )
            )
        }
        
        return state
    }
    
    func update(
        _ state: State,
        with productUpdate: FastPaymentsSettingsEvent.ProductUpdateResult
    ) -> State {
        
        guard let details = state.activeDetails
        else { return state }
        
        switch productUpdate {
        case let .success(productID):
            var details = details
            let product = product(forID: productID)
            details = details.updated(
                productSelector: details.productSelector.updated(
                    selectedProduct: product,
                    status: .collapsed
                )
            )
            
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
        _ productID: Product.ID
    ) -> Self {
        
        .updateProduct(.init(
            contractID: .init(details.paymentContract.id.rawValue),
            productID: productID
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
