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
        
        switch state.userPaymentSettings {
        case let .contracted(details):
#warning("add tests for branches")
            guard details.isInactive,
                  let core = details.core
            else { return (state, nil) }
            
            var state = state
            state.status = .inflight
            
            let updateContract = ContractEffect.TargetContract(
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
                        consentList: consent,
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

// MARK: - Adapters

private extension UserPaymentSettings.ContractDetails {
    
    var core: FastPaymentsSettingsEffect.ContractCore? {
        
        guard let product = productSelector.selectedProduct
        else { return nil }
        
        return .init(
            contractID: .init(paymentContract.id.rawValue),
            productID: product.id
        )
    }
}
