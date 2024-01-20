//
//  FastPaymentsSettingsReducer.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

public final class FastPaymentsSettingsReducer {
    
    private let getProducts: GetProducts
    
    public init(getProducts: @escaping GetProducts) {
        
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
            (state, effect) = update(state, with: bankDefault)
            
        case .activateContract:
            (state, effect) = activateContract(state)
            
        case .appear:
            (state, effect) = handleAppear(state)
            
        case .collapseProducts:
            state = collapseProducts(state)
            
        case .deactivateContract:
            (state, effect) = deactivateContract(state)
            
        case .expandProducts:
            state = expandProducts(state)
            
        case let .loadSettings(settings):
            state = handleLoadedSettings(settings)
            
        case .resetStatus:
            state = resetStatus(state)
            
        case let .selectProduct(product):
            (state, effect) = selectProduct(state, product)
            
        case let .updateContract(result):
            state = updateContract(state, with: result)
            
        case let .updateProduct(result):
            state = update(state, with: result)
        }
        
        return (state, effect)
    }
}

public extension FastPaymentsSettingsReducer {
    
    typealias GetProducts = () -> [Product]
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension FastPaymentsSettingsReducer {
    
    func activateContract(
        _ state: State
    ) -> (State, Effect?) {
        
        switch state.userPaymentSettings {
        case let .contracted(details):
#warning("add tests for branches")
            guard details.isInactive,
                  let core = details.core
            else { return (state, nil) }
            
            var state = state
            state.status = .inflight
            
            let updateContract = FastPaymentsSettingsEffect.TargetContract(
                core: core,
                targetStatus: .active
            )
            
            return (state, .activateContract(updateContract))
            
        case let .missingContract(consent):
            var state = state
            let products = getProducts()
            
#warning("add tests for branches")
            guard let product = products.first
            else {
                state.status = .missingProduct
                return (state, nil)
            }
            
            state.status = .inflight
            
            return (state, .createContract(.init(product.id.rawValue)))
            
        default:
            return (state, nil)
        }
    }
    
    func collapseProducts(
        _ state: State
    ) -> State {
        
        guard var details = state.activeDetails,
              details.productSelector.isExpanded
        else { return state }
        
        details.productSelector = details.productSelector.updated(status: .collapsed)
        
        return .init(userPaymentSettings: .contracted(details))
    }
    
    func deactivateContract(
        _ state: State
    ) -> (State, Effect?) {
        
#warning("add tests for branches")
        guard let details = state.activeDetails,
              let core = details.core
        else { return (state, nil) }
        
        var state = state
        state.status = .inflight
        
        let updateContract = FastPaymentsSettingsEffect.TargetContract(
            core: core,
            targetStatus: .inactive
        )
        
        return (state, .deactivateContract(updateContract))
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
    
    func prepareSetBankDefault(
        _ state: State
    ) -> (State, Effect?) {
        
        guard let details = state.activeDetails,
              details.bankDefault == .offEnabled,
              state.status == .setBankDefault
        else { return (state, nil) }
        
        var state = state
        state.status = nil
        
        return (state, .prepareSetBankDefault)
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
    
    func setBankDefault(
        _ state: State
    ) -> State {
        
        guard let details = state.activeDetails,
              details.bankDefault == .offEnabled
        else { return state }
        
        var state = state
        state.status = .setBankDefault
        
        return state
    }
    
    func update(
        _ state: State,
        with bankDefault: FastPaymentsSettingsEvent.BankDefault
    ) -> (State, Effect?) {
        var state = state
        var effect: Effect?
        
        switch bankDefault {
        case .prepareSetBankDefault:
            (state, effect) = prepareSetBankDefault(state)
            
        case .setBankDefault:
            state = setBankDefault(state)
            
        case let .setBankDefaultPrepared(failure):
            state = update(state, with: failure)
        }
        
        return (state, effect)
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
    
    func update(
        _ state: State,
        with failure: FastPaymentsSettingsEvent.Failure?
    ) -> State {
        
        guard let details = state.activeDetails
        else { return state }
        
        switch failure {
        case .none:
            var details = details
            details.bankDefault = .onDisabled
            return .init(
                userPaymentSettings: .contracted(details),
                status: .setBankDefaultSuccess
            )
            
        case .connectivityError:
            var state = state
            state.status = .connectivityError
            return state
            
        case let .serverError(message):
            var state = state
            state.status = .serverError(message)
            return state
        }
    }
    
    func updateContract(
        _ state: State,
        with result: FastPaymentsSettingsEvent.ContractUpdateResult
    ) -> State {
        
        switch state.userPaymentSettings {
        case var .contracted(details):
            switch result {
            case let .success(contract):
                details.paymentContract = contract
                return .init(userPaymentSettings: .contracted(details))
                
            case .failure(.connectivityError):
                var state = state
                state.status = .connectivityError
                return state
                
            case let .failure(.serverError(message)):
                var state = state
                state.status = .serverError(message)
                return state
            }
            
        case let .missingContract(consent):
            switch result {
            case let .success(contract):
                let products = getProducts()
                let product = products.first { $0.id == contract.productID }
                
                return .init(userPaymentSettings: .contracted(
                    .init(
                        paymentContract: contract,
                        consentResult: consent,
                        bankDefault: .offEnabled,
                        productSelector: .init(
                            selectedProduct: product,
                            products: products
                        )
                    )
                ))
                
            case .failure(.connectivityError):
                var state = state
                state.status = .connectivityError
                return state
                
            case let .failure(.serverError(message)):
                var state = state
                state.status = .serverError(message)
                return state
            }
            
        default:
            return state
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
    
    var isInactive: Bool {
        
        paymentContract.contractStatus == .inactive
    }
}

// MAKR: - Adapters

private extension UserPaymentSettings.ContractDetails {
    
    var core: FastPaymentsSettingsEffect.ContractCore? {
        
        guard let product = productSelector.selectedProduct
        else { return nil }
        
        return .init(
            contractID: .init(paymentContract.id.rawValue),
            product: product
        )
    }
}
