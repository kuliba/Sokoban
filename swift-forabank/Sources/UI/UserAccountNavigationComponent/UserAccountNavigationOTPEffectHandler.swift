//
//  UserAccountNavigationOTPEffectHandler.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import FastPaymentsSettings
import OTPInputComponent

public final class UserAccountNavigationOTPEffectHandler {
    
    private let makeTimedOTPInputViewModel: MakeTimedOTPInputViewModel
    private let prepareSetBankDefault: PrepareSetBankDefault
    private let scheduler: AnySchedulerOfDispatchQueue

    public init(
        makeTimedOTPInputViewModel: @escaping MakeTimedOTPInputViewModel,
        prepareSetBankDefault: @escaping PrepareSetBankDefault,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.makeTimedOTPInputViewModel = makeTimedOTPInputViewModel
        self.prepareSetBankDefault = prepareSetBankDefault
        self.scheduler = scheduler
    }
}

public extension UserAccountNavigationOTPEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .create(phoneNumber):
            dispatch(makeDestination(phoneNumber, dispatch))
            
        case let .prepareSetBankDefault(phoneNumber):
            prepareSetBankDefault { result in
                
                switch result {
                case .success(()):
                    dispatch(.prepareSetBankDefaultResponse(.success(phoneNumber)))
                    
                case .failure(.connectivityError):
                    dispatch(.prepareSetBankDefaultResponse(.connectivityError))
                    
                case let .failure(.serverError(message)):
                    dispatch(.prepareSetBankDefaultResponse(.serverError(message)))
                }
            }
        }
    }
}

public extension UserAccountNavigationOTPEffectHandler {
    
    typealias MakeTimedOTPInputViewModel = (OTPInputState.PhoneNumberMask, AnySchedulerOfDispatchQueue) -> TimedOTPInputViewModel
    typealias PrepareSetBankDefault = FastPaymentsSettingsEffectHandler.PrepareSetBankDefault
    typealias Dispatch = (Event) -> Void

    typealias Effect = UserAccountNavigation.Effect.OTP
    typealias Event = UserAccountNavigation.Event.OTP
}

private extension UserAccountNavigationOTPEffectHandler {
    
    func makeDestination(
        _ phoneNumber: OTPInputState.PhoneNumberMask,
        _ dispatch: @escaping Dispatch
    ) -> Event {
        
        let otpInputViewModel = makeTimedOTPInputViewModel(phoneNumber, scheduler)
        let cancellable = otpInputViewModel.$state
            .dropFirst()
            .compactMap(\.projection)
            .removeDuplicates()
            .map(Event.otpInput)
            .receive(on: scheduler)
            .sink { dispatch($0) }
        
        return .create(.init(otpInputViewModel, cancellable))
    }
}

// MARK: - OTP for Fast Payments Settings

private extension OTPInputState {
    
    var projection: OTPInputStateProjection? {
        
        switch status {
        case let .failure(otpFieldFailure):
            switch otpFieldFailure {
            case .connectivityError:
                return .failure(.connectivityError)
                
            case let .serverError(message):
                return .failure(.serverError(message))
            }
            
        case let .input(input):
            guard input.otpField.status == .inflight
            else { return nil }
            
            return .inflight
            
        case .validOTP:
            return .validOTP
        }
    }
}
