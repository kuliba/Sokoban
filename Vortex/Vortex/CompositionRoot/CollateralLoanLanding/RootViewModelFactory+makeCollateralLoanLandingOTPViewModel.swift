//
//  RootViewModelFactory+makeCollateralLoanLandingOTPViewModel.swift
//  Vortex
//
//  Created by Valentin Ozerov on 30.01.2025.
//

import CombineSchedulers
import Foundation
import OTPInputComponent

extension RootViewModelFactory {
    
    func makeCollateralLoanLandingOTPViewModel(
        phoneNumberMask: OTPInputState.PhoneNumberMask,
        scheduler: AnySchedulerOfDispatchQueue
    ) -> TimedOTPInputViewModel {

        .init(
            viewModel: .default(
                initialState: .starting(
                    phoneNumber: phoneNumberMask,
                    duration: settings.otpDuration
                ),
                duration: settings.otpDuration,
                length: settings.otpLength,
                initiateOTP: otpServices.initiateOTP,
                submitOTP: otpServices.submitOTP,
                scheduler: scheduler
            ),
            codeObserver: codeObserver,
            scheduler: scheduler
        )
    }
    
    func makeCollateralLoanLandingModel() -> CollateralLoanLandingModel {
        
        .init(
            otpServices: .init(
                initiateOTP: <#T##CountdownEffectHandler.InitiateOTP##CountdownEffectHandler.InitiateOTP##(@escaping CountdownEffectHandler.InitiateOTPCompletion) -> Void#>,
                submitOTP: <#T##OTPFieldEffectHandler.SubmitOTP##OTPFieldEffectHandler.SubmitOTP##(OTPFieldEffectHandler.SubmitOTPPayload, @escaping OTPFieldEffectHandler.SubmitOTPCompletion) -> Void#>
            )
        )
    }
        
//        
//        
//        return makeNavigationStateManager(
//            modelEffectHandler: .init(model: model),
//            otpServices: .init(
//                infra.httpClient,
//                infra.logger
//            ),
//            otpDeleteBankServices: .init(
//                for: infra.httpClient,
//                infoNetworkLog
//            ),
//            fastPaymentsFactory: fastPaymentsFactory,
//            makeSubscriptionsViewModel: makeSubscriptionsViewModel
//        )
//    }
}

extension RootViewModelFactory {
    
    typealias AnySchedulerOfDispatchQueue = AnySchedulerOf<DispatchQueue>
}
