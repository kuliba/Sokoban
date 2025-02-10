//
//  OpenCardDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

import FlowCore
import Foundation
import OrderCard
import OTPInputComponent
import PayHub
import RxViewModel

/// A namespace.
enum OpenCardDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<State, Event, Effect>
    
    typealias State = OrderCard.State<Confirmation>
    typealias Event = OrderCard.Event<Confirmation>
    typealias Effect = OrderCard.Effect
    
    typealias Reducer = OrderCard.Reducer<Confirmation>
    typealias EffectHandler = OrderCard.EffectHandler<Confirmation>
    
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
    
    typealias LoadConfirmationResult = OrderCard.LoadConfirmationResult<Confirmation>
    
    struct Confirmation {
        
        let otp: TimedOTPInputViewModel
        var consent: Consent
        
        struct Consent {
            
            var check: Bool
            let description: AttributedString
        }
    }
    
    typealias LoadFormResult = OrderCard.LoadFormResult<Confirmation>
    typealias LoadFailure = OrderCard.LoadFailure
    
    typealias OrderCardPayload = OrderCard.OrderCardPayload
    typealias OrderCardResult = Event.OrderCardResult
    typealias OrderCardResponse = OrderCard.OrderCardResponse
}
