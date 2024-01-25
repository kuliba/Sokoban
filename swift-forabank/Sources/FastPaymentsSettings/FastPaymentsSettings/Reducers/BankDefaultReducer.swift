//
//  BankDefaultReducer.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

#warning("add tests")
public final class BankDefaultReducer {
    
    public init() {}
}

public extension BankDefaultReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .prepareSetBankDefault:
            (state, effect) = prepareSetBankDefault(state)
            
        case .setBankDefault:
            state = setBankDefault(state)
            
        case let .setBankDefaultPrepared(failure):
            state = update(state, with: failure)
        }
        
        return (state, effect)
    }
}

public extension BankDefaultReducer {
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent.BankDefault
    typealias Effect = FastPaymentsSettingsEffect
    
}

private extension BankDefaultReducer {
    
    func prepareSetBankDefault(
        _ state: State
    ) -> (State, Effect?) {
        
        guard let details = state.activeDetails,
              details.bankDefault == .offEnabled,
              state.status == .setBankDefault
        else { return (state, nil) }
        
        var state = state
        state.status = .inflight
        
        return (state, .prepareSetBankDefault)
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
    
    #warning("`Failure` is not a member of `FastPaymentsSettingsEvent.BankDefault`")
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
}
