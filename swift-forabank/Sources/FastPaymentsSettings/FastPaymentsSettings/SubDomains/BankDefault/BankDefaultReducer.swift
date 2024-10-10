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
        case .deleteDefaultBank:
            (state, effect) = deleteDefaultBank(state)
          
        case let .prepareDeleteBank(response):
            state = prepareDeleteDefaultBank(state, with: response)
  
        case .prepareSetBankDefault:
            (state, effect) = prepareSetBankDefault(state)
            
        case .setBankDefault:
            state = setBankDefault(state)
            
        case let .setBankDefaultResult(result):
            state = update(state, with: result)
            
        case let .deleteBankDefaultResult(result):
            state = makeDeleteDefaultBankResult(state, with: result)
        }
        
        return (state, effect)
    }
}

public extension BankDefaultReducer {
    
    typealias State = FastPaymentsSettingsState
    typealias Event = BankDefaultEvent
    typealias Effect = FastPaymentsSettingsEffect
    
}

private extension BankDefaultReducer {
    
    func prepareDeleteDefaultBank(
        _ state: State
    ) -> (State, Effect?) {
        
        guard let details = state.activeDetails
        else { return (state, nil) }
        
        var state = state
        state.status = .inflight
        
        return (state, .prepareDeleteDefaultBank)
    }
    
    func deleteDefaultBank(
        _ state: State
    ) -> (State, Effect?) {
        
        guard let details = state.activeDetails
        else { return (state, nil) }
        
        var state = state
        state.status = .inflight
        
        return (state, .prepareDeleteDefaultBank)
    }
    
    func prepareSetBankDefault(
        _ state: State
    ) -> (State, Effect?) {
        
        guard let details = state.activeDetails,
              details.bankDefaultResponse.bankDefault == .offEnabled,
              details.bankDefaultResponse.requestLimitMessage == nil,
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
              details.bankDefaultResponse.bankDefault == .offEnabled,
              details.bankDefaultResponse.requestLimitMessage == nil
        else { return state }
        
        var state = state
        state.status = .setBankDefault
        
        return state
    }
    
    func update(
        _ state: State,
        with result: BankDefaultEvent.SetBankDefaultResult
    ) -> State {
        
        guard let details = state.activeDetails
        else { return state }
        
        switch result {
        case .success:
            var details = details
            details.bankDefaultResponse.bankDefault = .onDisabled
            return .init(
                settingsResult: .success(.contracted(details)),
                status: .setBankDefaultSuccess
            )
            
        case let .incorrectOTP(message):
            var state = state
            state.status = .setBankDefaultFailure(message)
            return state
            
        case .serviceFailure(.connectivityError):
            var state = state
            state.status = .connectivityError
            return state
            
        case let .serviceFailure(.serverError(message)):
            var state = state
            state.status = .serverError(message)
            return state
        }
    }
    
    func prepareDeleteDefaultBank(
        _ state: State,
        with result: BankDefaultEvent.SetBankDefaultResult
    ) -> State {
        
        guard let details = state.activeDetails
        else { return state }
   
        switch result {
        case .success:
            return .init(
                settingsResult: .active(bankDefaultResponse: .init(bankDefault: .offEnabled)),
                status: .deleteBankDefault(details.paymentContract.phoneNumberMasked.rawValue)
            )
            
        case let .incorrectOTP(message):
            var state = state
            state.status = .deleteDefaultBankFailure(message)
            return state
            
        case .serviceFailure(.connectivityError):
            var state = state
            state.status = .connectivityError
            return state
            
        case let .serviceFailure(.serverError(message)):
            var state = state
            state.status = .serverError(message)
            return state
        }
    }
    
    func makeDeleteDefaultBankResult(
        _ state: State,
        with result: BankDefaultEvent.SetBankDefaultResult
    ) -> State {
        
        guard let details = state.activeDetails
        else { return state }
   
        switch result {
        case .success:
            return .init(
                settingsResult: .success(.contracted(details)),
                status: .makeDeleteDefaultBankSuccess
            )
            
        case let .incorrectOTP(message):
            var state = state
            state.status = .deleteDefaultBankFailure(message)
            return state
            
        case .serviceFailure(.connectivityError):
            var state = state
            state.status = .connectivityError
            return state
            
        case let .serviceFailure(.serverError(message)):
            var state = state
            state.status = .serverError(message)
            return state
        }
    }
}

// MARK: - Helpers

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
