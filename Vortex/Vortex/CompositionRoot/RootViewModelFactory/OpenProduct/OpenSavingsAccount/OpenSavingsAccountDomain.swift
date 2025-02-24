//
//  OpenSavingsAccountDomain.swift
//  Vortex
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import Foundation
import FlowCore
import Foundation
import LoadableState
import SavingsAccount
import OTPInputComponent
import PayHub
import RxViewModel

/// A namespace.
enum OpenSavingsAccountDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<State, Event, Effect>
    
    typealias State = ProductState<Confirmation>
    typealias Event = ProductEvent<Confirmation>
    typealias Effect = ProductEffect
    
    typealias Reducer = SavingsAccount.Reducer<Confirmation>
    typealias EffectHandler = SavingsAccount.EffectHandler<Confirmation>
    
    typealias ConfirmationNotify = EffectHandler.ConfirmationNotify
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    typealias Witnesses = ContentWitnesses<Content, FlowEvent<Select, Never>>
    
    enum Select {
        
        case failure(LoadFailure)
    }
    
    enum Navigation {
        
        case failure(LoadFailure)
    }
    
    // MARK: - Other
    
    typealias LoadConfirmationResult = SavingsAccount.LoadConfirmationResult<Confirmation>
    
    struct Confirmation {
        
        let otp: TimedOTPInputViewModel
        let consent: Consent
        
        struct Consent {
            
            let description: AttributedString
        }
    }
    
    typealias LoadFormResult = SavingsAccount.LoadFormResult<Confirmation>
    typealias LoadFailure = LoadableState.LoadFailure
    
    typealias OrderAccountPayload = SavingsAccount.ProductEffect.OrderAccountPayload
    typealias OrderAccountResult = Event.OrderAccountResult
    typealias OrderAccountResponse = SavingsAccount.OrderAccountResponse
}
