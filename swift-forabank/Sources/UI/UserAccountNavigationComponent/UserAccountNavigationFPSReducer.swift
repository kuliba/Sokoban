//
//  UserAccountNavigationFPSReducer.swift
//
//
//  Created by Igor Malyarov on 27.01.2024.
//

import FastPaymentsSettings

public final class UserAccountNavigationFPSReducer {
    
    public init() {}
}

public extension UserAccountNavigationFPSReducer {
    
    func reduce(
        _ state: State,
        _ settings: FastPaymentsSettingsState
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch (settings.settingsResult, settings.status) {
        case (_, .inflight):
            state.isLoading = true
            
        case (nil, _):
            break
            
        case let (.success(.contracted(contracted)), nil):
            state.isLoading = false
            let message = contracted.bankDefaultResponse.requestLimitMessage
            state.destination?.alert = message.map { .error(
                message: $0,
                event: .closeFPSAlert
            ) }
            
        case (.success(.missingContract), nil):
            state.isLoading = false
            state.destination?.alert = .missingContract(event: .closeAlert)
            
        case let (.success, .some(status)):
            (state, effect) = update(state, with: status)
            
        case let (.failure(failure), _):
            // final => dismissRoute
            state.isLoading = false
            
            switch failure {
            case let .serverError(message):
                state.destination?.alert = .error(
                    message: message,
                    event: .dismissRoute
                )
                
            case .connectivityError:
                state.destination?.alert = .tryAgainFPSAlert(.dismissRoute)
            }
        }
        
        return (state, effect)
    }
}

public extension UserAccountNavigationFPSReducer {
    
    typealias Inform = (String) -> Void
    
    typealias State = UserAccountNavigation.State
    typealias Event = UserAccountNavigation.Event
    typealias Effect = UserAccountNavigation.Effect
}

private extension UserAccountNavigationFPSReducer {
    
    func update(
        _ state: State,
        with status: FastPaymentsSettingsState.Status
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch status {
        case .inflight:
            state.isLoading = true
            
        case let .getC2BSubResponse(getC2BSubResponse):
            state.isLoading = false
            state.destination?.destination = .c2BSub(getC2BSubResponse, nil)
            
        case .connectivityError:
            state.isLoading = false
            // non-final => closeAlert
            state.destination?.destination = nil
            state.destination?.alert = .tryAgainFPSAlert(.closeAlert)
            
        case let .serverError(message):
            state.isLoading = false
            // non-final => closeAlert
            state.destination?.alert = .error(
                message: message,
                event: .closeAlert
            )
            
        case .missingProduct:
            state.isLoading = false
            state.destination?.alert = .missingProduct(event: .dismissRoute)
            
        case .confirmSetBankDefault:
            // state.fpsDestination = .confirmSetBankDefault
            // effect = .fps(.resetStatus)
            fatalError("what should happen here?")
            
        case .setBankDefault:
            state.destination?.alert = .setBankDefault(
                event: .otp(.prepareSetBankDefault),
                secondaryEvent: .closeFPSAlert
            )
            
        case let .setBankDefaultFailure(message):
            state.isLoading = false
            state.destination?.destination = nil
            state.informer = message
            effect = .dismissInformer
#warning("effect = .fps(.resetStatus)")
            
        case .setBankDefaultSuccess:
            state.isLoading = false
            state.destination?.destination = nil
            state.informer = "Банк по умолчанию установлен."
            effect = .dismissInformer
#warning("effect = .fps(.resetStatus)")
            
        case .updateContractFailure:
            // state = .init()
            state.isLoading = false
            state.informer = "Ошибка изменения настроек СБП.\nПопробуйте позже."
            effect = .dismissInformer
        }
        
        return (state, effect)
    }
}
