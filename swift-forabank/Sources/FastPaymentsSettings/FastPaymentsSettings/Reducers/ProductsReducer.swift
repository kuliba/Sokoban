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
    typealias Event = ProductsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension UserPaymentSettings.ProductSelector {
    
    func isSelected(
        _ selectableProductID: SelectableProductID
    ) -> Bool {
        
        selectedProduct?.selectableProductID == selectableProductID
    }
}

private extension ProductsReducer {
    
    func canSelect(
        _ selectableProductID: SelectableProductID
    ) -> Bool {
        
        let selectableProductIDs = getProducts().map(\.selectableProductID)
        return selectableProductIDs.contains(selectableProductID)
    }
    
    func product(
        forID id: Product.ID
    ) -> Product? {
        
        getProducts().first(where: { $0.id == id })
    }
    
    func product(
        forSelectableProductID selectableProductID: SelectableProductID
    ) -> Product? {
        
        getProducts().first(where: { $0.selectableProductID == selectableProductID })
    }
    
    func selectProduct(
        _ state: State,
        _ selectableProductID: SelectableProductID
    ) -> (State, Effect?) {
        
        guard let details = state.activeDetails,
              details.productSelector.isExpanded
        else { return (state, nil) }
        
        guard !details.productSelector.isSelected(selectableProductID),
              canSelect(selectableProductID)
        else {
            var state = state
            state = .init(
                settingsResult: .success(.contracted(
                    details.updated(
                        productSelector: details.productSelector.updated(
                            status: .collapsed
                        )
                    )
                ))
            )
            return (state, nil)
        }
        
        var state = state
        state.status = .inflight
        
        let product = product(forSelectableProductID: selectableProductID)
        
        return (state, product.map { .updateProduct(details, $0) })
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
                settingsResult: .success(.contracted(
                    details.updated(
                        productSelector: details.productSelector.updated(
                            status: .expanded
                        )
                    )
                ))
            )
            
        case .expanded:
            state = .init(
                settingsResult: .success(.contracted(
                    details.updated(
                        productSelector: details.productSelector.updated(
                            status: .collapsed
                        )
                    )
                ))
            )
        }
        
        return state
    }
    
    func update(
        _ state: State,
        with productUpdate: ProductsEvent.ProductUpdateResult
    ) -> State {
        
        guard let details = state.activeDetails
        else { return state }
        
        switch productUpdate {
        case let .success(selectableProductID):
            var details = details
            let product = product(forSelectableProductID: selectableProductID)
            details = details.updated(
                productSelector: details.productSelector.updated(
                    selectedProduct: product,
                    status: .collapsed
                )
            )
            
            return .init(settingsResult: .success(.contracted(details)))
            
        case .failure(.connectivityError):
            var details = details
            details.productSelector = details.productSelector.updated(
                status: .collapsed
            )
            
            return .init(
                settingsResult: .success(.contracted(details)),
                status: .connectivityError
            )
            
        case let .failure(.serverError(message)):
            var details = details
            details.productSelector = details.productSelector.updated(
                status: .collapsed
            )
            
            return .init(
                settingsResult: .success(.contracted(details)),
                status: .serverError(message)
            )
        }
    }
}

// MARK: - Helpers

private extension FastPaymentsSettingsEffect {
    
    static func updateProduct(
        _ details: UserPaymentSettings.Details,
        _ product: Product
    ) -> Self {
        
        .updateProduct(.init(
            contractID: .init(details.paymentContract.id.rawValue),
            selectableProductID: product.selectableProductID
        ))
    }
}

private extension UserPaymentSettings.ProductSelector {
    
    var isExpanded: Bool { status == .expanded }
}

private extension FastPaymentsSettingsState {
    
    var activeDetails: UserPaymentSettings.Details? {
        
        guard case let .success(.contracted(details)) = settingsResult,
              details.isActive
        else { return nil }
        
        return details
    }
}

private extension UserPaymentSettings.Details {
    
    var isActive: Bool {
        
        paymentContract.contractStatus == .active
    }
}
