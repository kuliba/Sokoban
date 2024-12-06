//
//  UserAccountNavigationOTPReducer.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2024.
//

import FastPaymentsSettings
import OTPInputComponent
import RxViewModel

final class UserAccountNavigationOTPReducer {}

extension UserAccountNavigationOTPReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.link {
        case .fastPaymentSettings(.new):
            
            switch event {
            case let .create(route):
                state.fpsRoute?.destination = .confirmSetBankDefault(route.viewModel, route.cancellable)
                
            case let .otpInput(otpInput):
                switch state.link {
                case let .fastPaymentSettings(settings):
                    switch settings {
                    case let .new(route):
                        if route.destination?.id == .confirmDeleteDefaultBank {
                            
                            (state, effect) = reduceDeleteBank(state, otpInput)

                        } else {
                            
                            (state, effect) = reduce(state, otpInput)
                        }
                    default: break
                    }
                default: break
                }
            case .prepareSetBankDefault:
                (state, effect) = prepareSetBankDefault(state)
                
            case let .prepareSetBankDefaultResponse(response):
                (state, effect) = update(state, with: response)
                
            case let .createDeleteBank(route):
                state.spinner = nil
                state.fpsRoute?.destination = .confirmDeleteDefaultBank(route.viewModel, route.cancellable)

            }
            
        default:
            break
        }
        
        return (state, effect)
    }
}

extension UserAccountNavigationOTPReducer {
    
    typealias Inform = (String) -> Void
    typealias Dispatch = (Event) -> Void
    
    typealias State = UserAccountRoute
    typealias Event = UserAccountEvent.OTPEvent
    typealias Effect = UserAccountEffect
}

private extension UserAccountNavigationOTPReducer {
    
    func reduce(
        _ state: State,
        _ otpInput: OTPInputStateProjection
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch otpInput {
        case let .failure(failure):
            (state, effect) = reduce(state, failure)
            
        case .inflight:
            state.spinner = .init()
            
        case .validOTP:
            state.spinner = nil
            state.fpsRoute?.viewModel.event(.bankDefault(.setBankDefaultResult(.success)))
        }
        
        return (state, effect)
    }
    
    func reduceDeleteBank(
        _ state: State,
        _ otpInput: OTPInputStateProjection
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch otpInput {
        case let .failure(failure):
            (state, effect) = reduceDeleteBank(state, failure)
            
        case .inflight:
            state.spinner = .init()
            
        case .validOTP:
            state.spinner = nil
            state.fpsRoute?.viewModel.event(.bankDefault(.deleteBankDefaultResult(.success)))
        }
        
        return (state, effect)
    }
    
    func reduceDeleteBank(
        _ state: State,
        _ failure: OTPInputComponent.ServiceFailure
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.spinner = nil
        
        switch failure {
        case .connectivityError:
            state.fpsRoute?.viewModel.event(.bankDefault(.deleteBankDefaultResult(.serviceFailure(.connectivityError))))
            
        case let .serverError(message):
            let tryAgain = "Введен некорректный код. Попробуйте еще раз."
            if message == tryAgain {
                state.fpsRoute?.viewModel.event(.bankDefault(.deleteBankDefaultResult(.incorrectOTP(tryAgain))))
                
            } else {
                state.fpsRoute?.viewModel.event(.bankDefault(.deleteBankDefaultResult(.serviceFailure(.serverError(message)))))
            }
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ failure: OTPInputComponent.ServiceFailure
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.spinner = nil
        state.fpsRoute?.destination = nil
        
        switch failure {
        case .connectivityError:
            state.fpsRoute?.viewModel.event(.bankDefault(.setBankDefaultResult(.serviceFailure(.connectivityError))))
            
        case let .serverError(message):
            let tryAgain = "Введен некорректный код. Попробуйте еще раз."
            if message == tryAgain {
                state.fpsRoute?.viewModel.event(.bankDefault(.setBankDefaultResult(.incorrectOTP(tryAgain)))) //message: "Банк по умолчанию не установлен"
                
            } else {
                state.fpsRoute?.viewModel.event(.bankDefault(.setBankDefaultResult(.serviceFailure(.serverError(message)))))
            }
        }
        
        return (state, effect)
    }
    
    func prepareSetBankDefault(
        _ state: State
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        if let phoneNumber = state.phoneNumberMask {
            
            state.spinner = .init()
            state.fpsRoute?.viewModel.event(.resetStatus)
            effect = .navigation(.otp(.prepareSetBankDefault(phoneNumber)))
        }
        
        return (state, effect)
    }
    
    func update(
        _ state: State,
        with response: Event.PrepareSetBankDefaultResponse
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.spinner = nil
        state.fpsRoute?.viewModel.event(.resetStatus)
        
        switch response {
        case let .success(phoneNumber):
            effect = .navigation(.otp(.create(phoneNumber)))
            
        case .connectivityError:
            state.fpsRoute?.destination = nil
            state.informer = .failure("Ошибка изменения настроек СБП.\nПопробуйте позже.")
            effect = .navigation(.dismissInformer())
            
        case let .serverError(message):
            state.fpsRoute?.destination = nil
            state.fpsRoute?.alert = .error(message: message, event: .dismiss(.alert))
            effect = .navigation(.dismissInformer())
        }
        
        return (state, effect)
    }
}

private extension UserAccountNavigationOTPReducer.State {
    
    var phoneNumberMask: OTPInputState.PhoneNumberMask? {
        
        guard case let .success(.contracted(details)) = fpsRoute?.viewModel.state.settingsResult
        else { return nil }
        
        return .init(details.paymentContract.phoneNumberMasked.rawValue)
    }
}

// MARK: - OTP for Fast Payments Settings

public enum OTPInputStateProjection: Equatable {
    
    case failure(OTPInputComponent.ServiceFailure)
    case inflight
    case validOTP
}
