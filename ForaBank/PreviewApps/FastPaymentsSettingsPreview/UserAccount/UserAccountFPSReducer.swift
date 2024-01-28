//
//  UserAccountFPSReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 27.01.2024.
//

import FastPaymentsSettings

final class UserAccountFPSReducer {}

extension UserAccountFPSReducer {
    
    func reduce(
        _ state: State,
        _ settings: FastPaymentsSettingsState,
        _ inform: @escaping Inform
    ) -> (State, Effect?) {
        
        var state = state
        
        switch (settings.settingsResult, settings.status) {
        case (_, .inflight):
            state.isLoading = true
            
        case (nil, _):
            break
            
        case let (.success(.contracted(contracted)), nil):
            state.isLoading = false
            let message = contracted.bankDefaultResponse.requestLimitMessage
            state.fpsRoute?.alert = message.map { .error(
                message: $0,
                event: .closeAlert
            ) }
            
        case (.success(.missingContract), nil):
            state.isLoading = false
            state.fpsRoute?.alert = .missingContract(event: .closeAlert)
            
        case let (.success, .some(status)):
            state = update(state, with: status, inform)
            
        case let (.failure(failure), _):
            // final => dismissRoute
            state.isLoading = false

            switch failure {
            case let .serverError(message):
                state.fpsRoute?.alert = .error(
                    message: message,
                    event: .dismissRoute
                )
                
            case .connectivityError:
                state.fpsRoute?.alert = .tryAgainFPSAlert(.dismissRoute)
            }
        }
        
        return (state, nil)
    }
}

extension UserAccountFPSReducer {
    
    typealias Inform = (String) -> Void
    
    typealias State = UserAccountNavigation.State
    typealias Event = UserAccountNavigation.Event
    typealias Effect = UserAccountNavigation.Effect
}

private extension UserAccountFPSReducer {
    
    func update(
        _ state: State,
        with status: FastPaymentsSettingsState.Status,
        _ inform: @escaping Inform
    ) -> State {
        
        var state = state
        
        switch status {
        case .inflight:
            state.isLoading = true
            
        case let .getC2BSubResponse(getC2BSubResponse):
            state.isLoading = false
            state.fpsRoute?.destination = .c2BSub(getC2BSubResponse, nil)
            
        case .connectivityError:
            state.isLoading = false
            // non-final => closeAlert
            state.fpsRoute?.destination = nil
            state.fpsRoute?.alert = .tryAgainFPSAlert(.closeAlert)
            
        case let .serverError(message):
            state.isLoading = false
            // non-final => closeAlert
            state.fpsRoute?.alert = .error(
                message: message,
                event: .closeAlert
            )
            
        case .missingProduct:
            state.isLoading = false
            state.fpsRoute?.alert = .missingProduct(event: .dismissRoute)
            
        case .confirmSetBankDefault:
            // state.fpsDestination = .confirmSetBankDefault
            // effect = .fps(.resetStatus)
            fatalError("what should happen here?")
            
        case .setBankDefault:
            state.fpsRoute?.alert = .setBankDefault(
                event: .otp(.prepareSetBankDefault),
                secondaryEvent: .closeAlert
            )
            
        case let .setBankDefaultFailure(message):
            state.isLoading = false
            state.fpsRoute?.destination = nil
            inform(message)
            #warning("effect = .fps(.resetStatus)")
            
        case .setBankDefaultSuccess:
            state.isLoading = false
            state.fpsRoute?.destination = nil
            inform("Банк по умолчанию установлен.")
            #warning("effect = .fps(.resetStatus)")
            
        case .updateContractFailure:
            state.isLoading = false
            inform("Ошибка изменения настроек СБП.\nПопробуйте позже.")
            state = .init()
        }
        
        return state
    }
}
