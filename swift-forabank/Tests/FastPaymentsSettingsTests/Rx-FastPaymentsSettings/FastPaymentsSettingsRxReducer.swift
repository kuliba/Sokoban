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
        case .appear:
            (state, effect) = handleAppear(state)
            
        case let .loadedSettings(settings):
            state = handleLoadedSettings(settings)
            
        case .activateContract:
            (state, effect) = activateContract(state)
            
        case let .contractUpdate(contractUpdate):
            fatalError("unimplemented")
        case let .productUpdate(productUpdate):
            fatalError("unimplemented")
        case let .setBankDefaultPrepare(failure):
            fatalError("unimplemented")
        case .deactivateContract:
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
