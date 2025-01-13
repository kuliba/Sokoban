//
//  ContractReducer.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

#warning("add tests")
public final class ContractReducer {
    
    private let getProducts: GetProducts
    
    public init(getProducts: @escaping GetProducts) {
        self.getProducts = getProducts
    }
}

public extension ContractReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .activateContract:
            (state, effect) = activateContract(state)
            
        case .deactivateContract:
            (state, effect) = deactivateContract(state)
            
        case let .updateContract(result):
            state = updateContract(state, with: result)
        }
        
        return (state, effect)
    }
}

public extension ContractReducer {
    
    typealias GetProducts = () -> [Product]
    
    typealias State = FastPaymentsSettingsState
    typealias Event = ContractEvent
    typealias Effect = ContractEffect
}

private extension ContractReducer {
    
    func activateContract(
        _ state: State
    ) -> (State, Effect?) {
        
        switch state.settingsResult {
        case let .success(.contracted(details)):
#warning("add tests for branches")
            guard details.isInactive,
                  let core = coreOrFallback(for: details)
            else { return (state, nil) }
            
            var state = state
            state.status = .inflight
            
            let updateContract = ContractEffect.TargetContract(
                core: core,
                targetStatus: .active
            )
            
            return (state, .activateContract(updateContract))
            
        case let .success(.missingContract(consent)):
            var state = state
            let products = getProducts()
            
#warning("add tests for branches")
            guard let product = products.first
            else {
                state.status = .missingProduct
                return (state, nil)
            }
            
            state.status = .inflight
            
            return (state, .createContract(product))
            
        default:
            return (state, nil)
        }
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
        
        let updateContract = ContractEffect.TargetContract(
            core: core,
            targetStatus: .inactive
        )
        
        return (state, .deactivateContract(updateContract))
    }
    
    func updateContract(
        _ state: State,
        with result: ContractUpdateResult
    ) -> State {
        
        switch state.settingsResult {
        case var .success(.contracted(details)):
            switch result {
            case let .success(contract):
                details.paymentContract = contract
                return .init(settingsResult: .success(.contracted(details)))
                
            case .failure(.connectivityError):
                var state = state
                state.status = .connectivityError
                return state
                
            case let .failure(.serverError(message)):
                var state = state
                state.status = .serverError(message)
                return state
            }
            
        case let .success(.missingContract(consent)):
            switch result {
            case let .success(contract):
                let products = getProducts()
                let product = products.product(forAccountID: contract.accountID)
                
                return .init(settingsResult: .success(.contracted(
                    .init(
                        paymentContract: contract,
                        consentList: consent,
                        bankDefaultResponse: .init(
                            bankDefault: .offEnabled
                        ),
                        productSelector: .init(
                            selectedProduct: product,
                            products: products
                        )
                    )
                )))
                
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

private extension FastPaymentsSettingsState {
    
    var details: UserPaymentSettings.Details? {
        
        guard case let .success(.contracted(details)) = settingsResult
        else { return nil }
        
        return details
    }
}

private extension ContractReducer {
    
    func coreOrFallback(
        for details: UserPaymentSettings.Details
    ) -> FastPaymentsSettingsEffect.ContractCore? {
        
        details.core ?? fallback(for: details)
    }
    
    func fallback(
        for details: UserPaymentSettings.Details
    ) -> FastPaymentsSettingsEffect.ContractCore? {
        
        guard let product = getProducts().first
        else { return nil }
        
        return .init(
            contractID: .init(details.paymentContract.id.rawValue),
            selectableProductID: product.id.selectableProductID
        )
    }
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
    
    var isInactive: Bool {
        
        paymentContract.contractStatus == .inactive
    }
}

// MARK: - Adapters

private extension UserPaymentSettings.Details {
    
    var core: FastPaymentsSettingsEffect.ContractCore? {
        
        guard let product = productSelector.selectedProduct
        else { return nil }
        
        return .init(
            contractID: .init(paymentContract.id.rawValue),
            selectableProductID: product.id.selectableProductID
        )
    }
}

