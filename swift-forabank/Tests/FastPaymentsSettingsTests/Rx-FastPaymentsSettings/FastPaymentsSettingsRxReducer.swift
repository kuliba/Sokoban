//
//  FastPaymentsSettingsRxReducer.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings

final class FastPaymentsSettingsRxReducer {
    
    private let getProduct: GetProduct
    
    init(getProduct: @escaping GetProduct) {
        
        self.getProduct = getProduct
    }
}

extension FastPaymentsSettingsRxReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .activateContract:
            (state, effect) = activateContract(state)
            
        case .appear:
            (state, effect) = handleAppear(state)
            
        case let .contractUpdate(result):
            state = updateContract(state, with: result)
            
        case .deactivateContract:
            (state, effect) = deactivateContract(state)
            
        case let .loadedSettings(settings):
            state = handleLoadedSettings(settings)
            
        case let .productUpdate(productUpdate):
            state = update(state, with: productUpdate)
            
        case let .setBankDefaultPrepare(failure):
            fatalError("unimplemented")
        case .resetStatus:
            fatalError("unimplemented")
        case .setBankDefault:
            fatalError("unimplemented")
        case .prepareSetBankDefault:
            fatalError("unimplemented")
        case .confirmSetBankDefault:
            fatalError("unimplemented")
        }
        
        return (state, effect)
    }
}

extension FastPaymentsSettingsRxReducer {
    
    typealias GetProduct = () -> Product?
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension FastPaymentsSettingsRxReducer {
    
    func activateContract(
        _ state: State
    ) -> (State, Effect?) {
        
        switch state.userPaymentSettings {
        case let .contracted(details):
            guard details.isInactive else { return (state, nil) }
            
            var state = state
            state.status = .inflight
            
            let updateContract = FastPaymentsSettingsEffect.TargetContract(
                core: details.core,
                targetStatus: .active
            )
            
            return (state, .activateContract(updateContract))
            
        case let .missingContract(consent):
            var state = state
            guard let product = getProduct()
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
                guard let product = getProduct() else { return state }
                
                return .init(userPaymentSettings: .contracted(
                    .init(
                        paymentContract: contract,
                        consentResult: consent,
                        bankDefault: .offEnabled,
                        product: product.settingsProduct
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
    
    func deactivateContract(
        _ state: State
    ) -> (State, Effect?) {
        
        guard case let .contracted(details) = state.userPaymentSettings,
              !details.isInactive
        else { return (state, nil) }
        
        var state = state
        state.status = .inflight
        
        let updateContract = FastPaymentsSettingsEffect.TargetContract(
            core: details.core,
            targetStatus: .inactive
        )
        
        return (state, .deactivateContract(updateContract))
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
    
    func update(
        _ state: State,
        with productUpdate: FastPaymentsSettingsEvent.Failure?
    ) -> State {
        
        guard case let .contracted(details) = state.userPaymentSettings,
              !details.isInactive
        else { return state }
        
        switch productUpdate {
        case .none:
            return state
            
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
}

private extension UserPaymentSettings.ContractDetails {
    
    var isInactive: Bool {
        
        paymentContract.contractStatus == .inactive
    }
}

// MAKR: - Adapters

private extension UserPaymentSettings.ContractDetails {
    
    var core: FastPaymentsSettingsEffect.ContractCore {
        
        .init(
            contractID: .init(paymentContract.id.rawValue),
            productID: .init(product.id.rawValue),
            productType: product.type.coreType
        )
    }
}

private extension UserPaymentSettings.Product.ProductType {
    
    var coreType: FastPaymentsSettingsEffect.ContractCore.ProductType {
        
        switch self {
        case .account: return .account
        case .card:    return .card
        }
    }
}

private extension Product {
    
    var settingsProduct: UserPaymentSettings.Product {
        
        .init(id: .init(id.rawValue), type: settingsProductType)
    }
    
    var settingsProductType: UserPaymentSettings.Product.ProductType {
        
        switch productType {
        case .account: return .account
        case .card:    return .card
        }
    }
}
