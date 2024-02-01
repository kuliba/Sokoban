//
//  Services+makeNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine
import Foundation
import OTPInputComponent
import Tagged
import UserAccountNavigationComponent

private extension FastPaymentsSettingsOTPServices {
    
#warning("add live services")
    static func live(httpClient: HTTPClient) -> Self {
        
        unimplemented()
    }
}

extension Services {
    
#warning("remove model if unused")
    static func makeNavigationStateManager(
        useStub isStub: Bool = true,
        httpClient: HTTPClient,
        model: Model,
        log: @escaping (String, StaticString, UInt) -> Void,
        duration: Int = 10,
        length: Int = 6,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) -> NavigationStateManager {
        
        let fpsReducer = UserAccountNavigationFPSReducer()
        
        let otpServices: FastPaymentsSettingsOTPServices = isStub ? .stub : .live(httpClient: httpClient)
        
        let otpReducer = UserAccountNavigationOTPReducer(
            makeTimedOTPInputViewModel: {
                
                .init(
                    viewModel: .default(
                        initialState: nil,
                        duration: duration,
                        length: length,
                        initiateOTP: otpServices.initiateOTP,
                        submitOTP: otpServices.submitOTP,
                        scheduler: $0
                    ),
                    scheduler: $0
                )
            },
            scheduler: .main
        )
        
        let otpEffectHandler = UserAccountNavigationOTPEffectHandler(
            prepareSetBankDefault: otpServices.prepareSetBankDefault
        )
        
        return .init(
            fpsReducer: fpsReducer,
            otpReducer: otpReducer,
            otpEffectHandler: otpEffectHandler
        )
    }
}

private struct FastPaymentsSettingsOTPServices {
    
    let initiateOTP: CountdownEffectHandler.InitiateOTP
    let submitOTP: OTPFieldEffectHandler.SubmitOTP
    let prepareSetBankDefault: UserAccountNavigationOTPEffectHandler.PrepareSetBankDefault
}

// MARK: - Adapters

private extension NavigationStateManager {
    
    init(
        fpsReducer: UserAccountNavigationFPSReducer,
        otpReducer: UserAccountNavigationOTPReducer,
        otpEffectHandler: UserAccountNavigationOTPEffectHandler
    ) {
        self.init(
            fpsReduce: fpsReducer.reduce(_:_:),
            otpReduce: otpReducer.reduce(_:_:_:),
            handleOTPEffect: otpEffectHandler.handleEffect(_:dispatch:)
        )
    }
}

private extension UserAccountNavigation.State {
    
    init(_ route: UserAccountRoute) {
        
#warning("ignoring alert state")
        self.init(
            destination: route.fpsRoute,
            alert: nil,
            isLoading: route.spinner != nil
        )
    }
}

private extension UserAccountRoute {
    
    var fpsRoute: UserAccountNavigation.State.FPSRoute? {
        
        guard case let .fastPaymentSettings(.new(fpsRoute)) = link
        else { return nil }
        
        return fpsRoute
    }
}

#warning("both adapters for `UserAccountNavigationFPSReducer` and `UserAccountNavigationOTPReducer` below use the same adaptation pattern")

private extension UserAccountNavigationFPSReducer {
    
    func reduce(
        _ state: UserAccountRoute,
        _ fpsEvent: UserAccountEvent.FastPaymentsSettings
    ) -> (UserAccountRoute, UserAccountEffect?) {
        
        var state = state
        var effect: UserAccountEffect?
        
        switch (state.link, fpsEvent) {
        // case let (.fastPaymentSettings(.new(fpsRoute)), .updated(settings)):
        case let (.fastPaymentSettings(.new), .updated(settings)):
            
            let (fpsState, fpsEffect) = reduce(.init(state), settings, { _ in })
            state = state.updated(with: fpsState)
            effect = fpsEffect.map(UserAccountEffect.navigation)

        default:
            break
        }
        
        return (state, effect)
    }
}

private extension UserAccountNavigationOTPReducer {
    
    func reduce(
        _ state: UserAccountRoute,
        _ event: UserAccountEvent.OTP,
        _ dispatch: @escaping (UserAccountEvent.OTP) -> Void
    ) -> (UserAccountRoute, UserAccountEffect?) {
        
        var state = state
        var effect: UserAccountEffect?
        
        switch state.link {
        // case let .fastPaymentSettings(.new(fpsRoute)):
        case .fastPaymentSettings(.new):
            
            let (fpsState, fpsEffect) = reduce(
                .init(state),
                event,
                { _ in },
                { dispatch($0) }
            )
            state = state.updated(with: fpsState)
            effect = fpsEffect.map(UserAccountEffect.navigation)
            
        default:
            break
        }
        
        return (state, effect)
    }
}

// MARK: - Helpers

private extension UserAccountRoute {
    
    func updated(with state: UserAccountNavigation.State) -> Self {
        
        var route = self
        route.link = .init(state)
#warning("ignoring alert state!!!!!!!")
        route.spinner = state.isLoading ? .init() : nil
        
        return route
    }
}

private extension UserAccountRoute.Link {
    
    init?(_ state: UserAccountNavigation.State) {
        
        switch state.destination {
        case let .some(fpsRoute):
            self = .fastPaymentSettings(.new(fpsRoute))
            
        default:
            return nil
        }
    }
}

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

// MARK: - Stubs

private extension FastPaymentsSettingsOTPServices {
    
    static let stub: Self = .init(
        initiateOTP: { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success(()))
            }
        },
        submitOTP: { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success(()))
            }
        },
        prepareSetBankDefault: { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(.success(()))
            }
        }
    )
}
