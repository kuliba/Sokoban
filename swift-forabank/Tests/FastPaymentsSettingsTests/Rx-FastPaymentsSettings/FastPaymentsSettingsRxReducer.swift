//
//  FastPaymentsSettingsRxReducer.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings

final class FastPaymentsSettingsRxReducer {
    
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
            
        case let .loadedUserPaymentSettings(userPaymentSettings):
            state = handleLoadedUserPaymentSettings(userPaymentSettings)
            
        case .activateContract:
            (state, effect) = activateContract(state)
            
        case let .updatedSuccess(status):
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

private extension FastPaymentsSettingsRxReducer {
    
    func handleAppear(
        _ state: State
    ) -> (State, Effect) {
        
        var state = state
        state.status = .inflight
        
        return (state, .getUserPaymentSettings)
    }
    
    func handleLoadedUserPaymentSettings(
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
            return (state, .activateContract(details.paymentContract))
            
//        case let .missingContract(consent):
//            var state = state
//            state.status = .inflight
//            guard let product = getProduct()
//            else {
//                state?.status = .missingProduct
//                return (state, nil)
//            }
//            
//            createContract(product, consent)
//            
//            return (state, .activateContract(contractDetails.paymentContract))
            
        default:
            return (state, nil)
        }
    }
}

extension FastPaymentsSettingsRxReducer {
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension UserPaymentSettings.ContractDetails {
    
    var isInactive: Bool {
        
        paymentContract.contractStatus == .inactive
    }
}
