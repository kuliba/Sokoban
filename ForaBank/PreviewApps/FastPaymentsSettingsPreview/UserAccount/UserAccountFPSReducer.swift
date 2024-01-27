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
            #warning("add helpers- like mutating funcs")
            switch state.destination {
            case .none:
                break
                
            case var .fastPaymentsSettings(fpsRoute):
                fpsRoute.alert = message.map { .error(
                    message: $0,
                    event: .closeAlert
                ) }
                state.destination = .fastPaymentsSettings(fpsRoute)
            }
            
        case (.success(.missingContract), nil):
            state.isLoading = false
            #warning("add helpers- like mutating funcs")
            switch state.destination {
            case .none:
                break
                
            case var .fastPaymentsSettings(fpsRoute):
                fpsRoute.alert = .missingContract(event: .closeAlert)
                state.destination = .fastPaymentsSettings(fpsRoute)
            }
            
        case let (.success, .some(status)):
            state = update(state, with: status, inform)
            
        case let (.failure(failure), _):
            // final => dismissRoute
            switch failure {
            case let .serverError(message):
                state.isLoading = false
                #warning("add helpers- like mutating funcs")
                switch state.destination {
                case .none:
                    break
                    
                case var .fastPaymentsSettings(fpsRoute):
                    fpsRoute.alert = .error(
                        message: message,
                        event: .dismissRoute
                    )
                    state.destination = .fastPaymentsSettings(fpsRoute)
                }

            case .connectivityError:
                state.isLoading = false
                switch state.destination {
                case .none:
                    break
                    
                case var .fastPaymentsSettings(fpsRoute):
                    fpsRoute.alert = .tryAgainFPSAlert(.dismissRoute)
                    state.destination = .fastPaymentsSettings(fpsRoute)
                }
            }
        }
        
        return (state, nil)
    }
}

extension UserAccountFPSReducer {
    
    typealias Inform = (String) -> Void
    
    typealias State = UserAccountViewModel.State
    typealias Event = UserAccountViewModel.Event
    typealias Effect = UserAccountViewModel.Effect
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
            #warning("add helpers- like mutating funcs")
            switch state.destination {
            case .none:
                break
                
            case var .fastPaymentsSettings(fpsRoute):
                fpsRoute.destination = .c2BSub(getC2BSubResponse, nil)
                state.destination = .fastPaymentsSettings(fpsRoute)
            }

        case .connectivityError:
            state.isLoading = false
            // non-final => closeAlert
            #warning("add helpers- like mutating funcs")
            switch state.destination {
            case .none:
                break
                
            case var .fastPaymentsSettings(fpsRoute):
                fpsRoute.alert = .tryAgainFPSAlert(.closeAlert)
                state.destination = .fastPaymentsSettings(fpsRoute)
            }

        case let .serverError(message):
            state.isLoading = false
            // non-final => closeAlert
            #warning("add helpers- like mutating funcs")
            switch state.destination {
            case .none:
                break
                
            case var .fastPaymentsSettings(fpsRoute):
                fpsRoute.alert = .ok(
                    message: message,
                    event: .closeAlert
                )
                state.destination = .fastPaymentsSettings(fpsRoute)
            }
            
        case .missingProduct:
            state.isLoading = false
            #warning("add helpers- like mutating funcs")
            switch state.destination {
            case .none:
                break
                
            case var .fastPaymentsSettings(fpsRoute):
                fpsRoute.alert = .missingProduct(event: .dismissRoute)
                state.destination = .fastPaymentsSettings(fpsRoute)
            }

        case .confirmSetBankDefault:
            // state.fpsDestination = .confirmSetBankDefault
            // effect = .fps(.resetStatus)
            fatalError("what should happen here?")
            
        case .setBankDefault:
            #warning("add helpers- like mutating funcs")
            switch state.destination {
            case .none:
                break
                
            case var .fastPaymentsSettings(fpsRoute):
                fpsRoute.alert = .setBankDefault(
                    primaryEvent: .otp(.prepareSetBankDefault),
                    secondaryEvent: .closeAlert
                )
                state.destination = .fastPaymentsSettings(fpsRoute)
            }

        case .setBankDefaultSuccess:
            state.isLoading = false
            inform("Банк по умолчанию установлен.")
            
        case .updateContractFailure:
            state.isLoading = false
            inform("Ошибка изменения настроек СБП.\nПопробуйте позже.")
            state = .init()
        }
        
        return state
    }
}
