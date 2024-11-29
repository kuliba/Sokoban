//
//  RootViewModelFactory+makeNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine
import Foundation
import GenericRemoteService
import OTPInputComponent
import RemoteServices
import Tagged
import UIPrimitives
import UserAccountNavigationComponent
import ForaTools

extension RootViewModelFactory {
    
    @inlinable
    func makeNavigationStateManager(
        modelEffectHandler: UserAccountModelEffectHandler,
        otpServices: FastPaymentsSettingsOTPServices,
        otpDeleteBankServices: FastPaymentsSettingsOTPServices,
        fastPaymentsFactory: FastPaymentsFactory,
        makeSubscriptionsViewModel: @escaping UserAccountNavigationStateManager.MakeSubscriptionsViewModel
    ) -> UserAccountNavigationStateManager {
        
        let duration = settings.otpDuration
        let length = settings.otpLength
        
        let fpsReducer = ForaBank.UserAccountNavigationFPSReducer()
        let otpReducer = ForaBank.UserAccountNavigationOTPReducer()
        
        let codeObserver = NotificationCenter.default
            .observe(
                notificationName: "otpCode",
                userInfoKey: "otp"
            )
        
        let userAccountReducer = UserAccountReducer(
            fpsReduce: fpsReducer.reduce(_:_:),
            otpReduce: otpReducer.reduce(_:_:)
        )
        
        let otpEffectHandler = UserAccountNavigationOTPEffectHandler(
            makeTimedOTPInputViewModel: {
                
                .init(
                    viewModel: .default(
                        initialState: .starting(
                            phoneNumber: $0,
                            duration: duration
                        ),
                        duration: duration,
                        length: length,
                        initiateOTP: otpServices.initiateOTP,
                        submitOTP: otpServices.submitOTP,
                        scheduler: $1
                    ),
                    codeObserver: codeObserver,
                    scheduler: $1
                )
            },
            makeTimedOTPInputDeleteDefaultBankViewModel: {
                
                .init(
                    viewModel: .default(
                        initialState: .starting(
                            phoneNumber: $0,
                            duration: duration
                        ),
                        duration: duration,
                        length: length,
                        initiateOTP: otpDeleteBankServices.initiateOTP,
                        submitOTP: otpDeleteBankServices.submitOTP,
                        scheduler: $1
                    ),
                    codeObserver: codeObserver,
                    scheduler: $1
                )
            },
            prepareSetBankDefault: otpServices.prepareSetBankDefault,
            scheduler: schedulers.main
        )
        
        let userAccountEffectHandler = UserAccountEffectHandler(
            handleModelEffect: modelEffectHandler.handleEffect(_:_:),
            handleOTPEffect: otpEffectHandler.handleEffect(_:dispatch:)
        )
        
        return .init(
            fastPaymentsFactory: fastPaymentsFactory,
            makeSubscriptionsViewModel: makeSubscriptionsViewModel,
            reduce: userAccountReducer.reduce(_:_:),
            handleEffect: userAccountEffectHandler.handleEffect(_:_:)
        )
    }
}

struct FastPaymentsSettingsOTPServices {
    
    let initiateOTP: CountdownEffectHandler.InitiateOTP
    let submitOTP: OTPFieldEffectHandler.SubmitOTP
    let prepareSetBankDefault: UserAccountNavigationOTPEffectHandler.PrepareSetBankDefault
}

// MARK: - Adapters

extension Array where Element == FastPaymentContractFullInfoType {
    
    private var phoneNumber: String? {
        
        guard
            let list = first?.fastPaymentContractAttributeList,
            let phoneNumber = list.first?.phoneNumber,
            !phoneNumber.isEmpty
        else { return nil }
        
        return phoneNumber
    }
}

private extension FastPaymentContractFullInfoType {
    
    var hasTripleYes: Bool {
        
        guard let accountAttributeList = fastPaymentContractAccountAttributeList?.first,
              let contractAttributeList = fastPaymentContractAttributeList?.first
        else { return false }
        
        return accountAttributeList.flagPossibAddAccount == .yes
        && contractAttributeList.flagClientAgreementIn == .yes
        && contractAttributeList.flagClientAgreementOut == .yes
    }
    
    var hasTripleNo: Bool {
        
        guard let accountAttributeList = fastPaymentContractAccountAttributeList?.first,
              let contractAttributeList = fastPaymentContractAttributeList?.first
        else { return false }
        
        return accountAttributeList.flagPossibAddAccount == .no
        && contractAttributeList.flagClientAgreementIn == .no
        && contractAttributeList.flagClientAgreementOut == .no
    }
}
