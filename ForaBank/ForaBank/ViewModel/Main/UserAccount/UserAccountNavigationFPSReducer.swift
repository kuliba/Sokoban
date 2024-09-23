//
//  UserAccountNavigationFPSReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.02.2024.
//

import FastPaymentsSettings
import UIPrimitives

final class UserAccountNavigationFPSReducer {}

extension UserAccountNavigationFPSReducer {
    
    func reduce(
        _ state: UserAccountRoute,
        _ fpsEvent: UserAccountEvent.FastPaymentsSettings
    ) -> (UserAccountRoute, UserAccountEffect?) {
        
        var state = state
        var effect: UserAccountEffect?
        
        switch (state.link, fpsEvent) {
            // case let (.fastPaymentSettings(.new(fpsRoute)), .updated(settings)):
        case let (.fastPaymentSettings(.new), .updated(settings)):
            
            (state, effect) = reduce(state, settings)
            
        default:
            break
        }
        
        return (state, effect)
    }

    func reduce(
        _ state: State,
        _ settings: FastPaymentsSettingsState
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch (settings.settingsResult, settings.status) {
        case (_, .inflight):
            state.spinner = .init()
            
        case (nil, _):
            break
            
        case let (.success(.contracted(contracted)), nil):
            state.spinner = nil
            let message = contracted.bankDefaultResponse.requestLimitMessage
            state.fpsRoute?.alert = message.map { .error(
                message: $0,
                event: .dismiss(.fpsAlert)
            ) }
            
        case (.success(.missingContract), nil):
            state.spinner = nil
            state.fpsRoute?.alert = .missingContract(event: .dismiss(.alert))
            
        case let (.success, .some(status)):
            (state, effect) = update(state, with: status)
            
        case let (.failure(failure), _):
            // final => dismissRoute
            state.spinner = nil
            
            switch failure {
            case let .serverError(message):
                state.fpsRoute?.alert = .error(
                    message: message,
                    event: .dismiss(.route)
                )
                
            case .connectivityError:
                state.fpsRoute?.alert = .tryAgainFPSAlert(.dismiss(.route))
            }
        }
        
        return (state, effect)
    }
}

extension UserAccountRoute {
    
    var fpsRoute: UserAccountRoute.FPSRoute? {
        
        get {
            
            guard case let .fastPaymentSettings(.new(fpsRoute)) = link
            else { return nil }
            
            return fpsRoute
        }
        
        set(newValue) {
            
            guard let newValue else { return }
            
            link = .fastPaymentSettings(.new(newValue))
        }
    }
}

extension UserAccountNavigationFPSReducer {
    
    typealias Inform = (String) -> Void
    
    typealias State = UserAccountRoute
    typealias Event = UserAccountEvent.FastPaymentsSettings
    typealias Effect = UserAccountEffect
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
            state.spinner = .init()
            
        case .connectivityError:
            state.spinner = nil
            state.fpsRoute?.destination = nil
            state.informer = .failure("Ошибка изменения настроек СБП.\nПопробуйте позже.")
            effect = .navigation(.dismissInformer())
            
        case let .serverError(message):
            state.spinner = nil
            // non-final => closeAlert
            state.fpsRoute?.alert = .error(
                message: message,
                event: .dismiss(.alert)
            )
            
        case .missingProduct:
            state.spinner = nil
            state.fpsRoute?.alert = .missingProduct(event: .dismiss(.route))
            
        case .confirmSetBankDefault:
            // state.fpsDestination = .confirmSetBankDefault
            // effect = .fps(.resetStatus)
            fatalError("what should happen here?")
            
        case .setBankDefault:
            state.fpsRoute?.alert = .setBankDefault(
                event: .otp(.prepareSetBankDefault),
                secondaryEvent: .dismiss(.fpsAlert)
            )
            
        case let .setBankDefaultFailure(message):
            state.spinner = nil
            state.fpsRoute?.destination = nil
            state.informer = .failure(message)
            effect = .navigation(.dismissInformer())
#warning("effect = .fps(.resetStatus)")
            
        case .setBankDefaultSuccess:
            state.spinner = nil
            state.fpsRoute?.destination = nil
            state.informer = .success("Банк по умолчанию установлен.")
            effect = .navigation(.dismissInformer())
#warning("effect = .fps(.resetStatus)")
            
        case .updateContractFailure:
            state.spinner = nil
            state.informer = .failure("Ошибка изменения настроек СБП.\nПопробуйте позже.")
            effect = .navigation(.dismissInformer())
            
        case .getC2BSubResponse(_):
            // ignoring for now
            break
        }
        
        return (state, effect)
    }
}

// MARK: - Alert Helpers

extension UserAccountRoute.Informer {
    
    static func failure(_ message: String) -> Self {
        
        .init(icon: .failure, message: message)
    }
    
    static func success(_ message: String) -> Self {
        
        .init(icon: .success, message: message)
    }
}

extension AlertModelOf<UserAccountEvent> {
    
    private static func `default`(
        title: String,
        message: String?,
        primaryEvent: PrimaryEvent,
        secondaryEvent: SecondaryEvent? = nil
    ) -> Self {
        
        .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: primaryEvent
            ),
            secondaryButton: secondaryEvent.map {
                
                .init(
                    type: .cancel,
                    title: "Отмена",
                    event: $0
                )
            }
        )
    }
    
    static func error(
        message: String? = nil,
        event: PrimaryEvent
    ) -> Self {
        
        .default(
            title: message != .errorRequestLimitExceeded ? "Ошибка" : "",
            message: message,
            primaryEvent: event
        )
    }
    
    static func missingContract(
        event: PrimaryEvent
    ) -> Self {
        
        .default(
            title: "Включите переводы СБП",
            message: "Для подключения СБП переведите ползунок в состояние – ВКЛ.\nПосле этого вы сможете отправлять и получать переводы СБП.",
            primaryEvent: event
        )
    }
    
    static func missingProduct(
        event: PrimaryEvent
    ) -> Self {
        
        .default(
            title: "Сервис не доступен",
            message: "Для подключения договора СБП у Вас должен быть подходящий продукт",
            primaryEvent: event
        )
    }
    
    static func setBankDefault(
        event: PrimaryEvent,
        secondaryEvent: SecondaryEvent
    ) -> Self {
        
        .default(
            title: "Внимание",
            message: "Фора-банк будет выбран банком по умолчанию",
            primaryEvent: event,
            secondaryEvent: secondaryEvent
        )
    }
    
    static func tryAgainFPSAlert(
        _ event: PrimaryEvent
    ) -> Self {
        
        let message = "Превышено время ожидания. Попробуйте позже"
        
        return .error(message: message, event: event)
    }
}
