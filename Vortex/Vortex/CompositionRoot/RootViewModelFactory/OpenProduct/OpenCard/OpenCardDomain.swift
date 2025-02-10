//
//  OpenCardDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

import FlowCore
// import OrderCard
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
        
        case failure(OrderCard.LoadFailure)
    }
    
    enum Navigation {
        
        case failure(OrderCard.LoadFailure)
    }
    
    // MARK: - Other
    
    typealias LoadConfirmationResult = OrderCard.LoadConfirmationResult<Confirmation>
    
    struct Confirmation {
        
        let otp: TimedOTPInputViewModel
        var consent: Consent
        
        struct Consent {
            
            var check: Bool
        }
    }
    
    typealias LoadFormResult = OrderCard.LoadFormResult<Confirmation>
    typealias LoadFailure = OrderCard.LoadFailure
    
    typealias OrderCardPayload = OrderCard.OrderCardPayload
    typealias OrderCardResult = OrderCard.OrderCardResult
    typealias OrderCardResponse = OrderCard.OrderCardResponse
}

enum OrderCard { // TODO: replace stub with types from module
    
    struct State<Confirmation> {
        
        var isLoading: Bool = false
        var formResult: LoadFormResult<Confirmation>?
    }
    
    struct Form<Confirmation> {
        
        let requestID: String
        let cardApplicationCardType: String
        let cardProductExtID: String
        let cardProductName: String
        
        var confirmation: LoadConfirmationResult<Confirmation>?
        var consent = true
        var messages: Messages
        var otp: String?
        var orderCardResponse: OrderCardResponse?
        
        struct Messages: Equatable {
            
            let description: String
            let icon: String
            let subtitle: String
            let title: String
            var isOn: Bool
        }
    }
    
    typealias LoadFormResult<Confirmation> = Result<Form<Confirmation>, LoadFailure>
    typealias LoadConfirmationResult<Confirmation> = Result<Confirmation, LoadFailure>
    
    struct LoadFailure: Error, Equatable {
        
        let message: String
        let type: FailureType
        
        enum FailureType {
            
            case alert, informer
        }
    }
    
    enum Event<Confirmation> {
        
        case `continue`
        case dismissInformer
        case load
        case loaded(LoadFormResult<Confirmation>)
        case loadConfirmation(LoadConfirmationResult<Confirmation>)
        case setMessages(Bool)
        case orderCardResult(OrderCardResult)
        case otp(String)
        case setConsent(Bool)
    }
    
    enum Effect: Equatable {
        
        case load
        case loadConfirmation
        case orderCard(OrderCardPayload)
    }
    
    struct OrderCardPayload: Equatable {
        
        let requestID: String
        let cardApplicationCardType: String
        let cardProductExtID: String
        let cardProductName: String
        let smsInfo: Bool
        let verificationCode: String
    }
    
    typealias OrderCardResult = Result<OrderCardResponse, LoadFailure>
    typealias OrderCardResponse = Bool
    
    final class Reducer<Confirmation> {

        private let otpWitness: OTPWitness
        typealias OTPWitness = (Confirmation) -> (String) -> Void
        
        init(
            otpWitness: @escaping OTPWitness
        ) {
            self.otpWitness = otpWitness
        }
        
        func reduce(
            _ state: State,
            _ event: Event
        ) -> (State, Effect?) {
            
            var state = state
            var effect: Effect?
            
            switch event {
            case .continue:
                reduceContinue(&state, &effect)
                
            case .dismissInformer:
                reduceDismissInformer(&state, &effect)
                
            case .load:
                state.isLoading = true
                effect = .load
                
            case let .loadConfirmation(confirmation):
                state.isLoading = false
                state.form?.confirmation = confirmation
                
            case let .loaded(result):
                state.isLoading = false
                state.formResult = result
                
            case let .setMessages(isOn):
                if !state.isLoading {
                    state.form?.messages.isOn = isOn
                }
                
            case let .orderCardResult(orderCardResult):
                // TODO: extract to helper
                state.isLoading = false
                
                switch orderCardResult {
                case let .failure(loadFailure):
                    let notifyOTP = state.form?.confirmation?.success.map(otpWitness)
                    notifyOTP?(loadFailure.message)
                    
                case let .success(orderCardResponse):
                    state.form?.orderCardResponse = orderCardResponse
                }
                
            case let .otp(otp):
                if !state.isLoading && state.hasConfirmation {
                    state.form?.otp = otp
                }
                
            case let .setConsent(consent):
                if !state.isLoading && state.hasConfirmation {
                    state.form?.consent = consent
                }
            }
            
            return (state, effect)
        }
        
        typealias State = OrderCard.State<Confirmation>
        typealias Event = OrderCard.Event<Confirmation>
        typealias Effect = OrderCard.Effect
    }
    
    final class EffectHandler<Confirmation> {
        
        private let load: Load
        private let loadConfirmation: LoadConfirmation
        private let orderCard: OrderCard
        
        init(
            load: @escaping Load,
            loadConfirmation: @escaping LoadConfirmation,
            orderCard: @escaping OrderCard
        ) {
            self.load = load
            self.loadConfirmation = loadConfirmation
            self.orderCard = orderCard
        }
        
        typealias DismissInformer = () -> Void
        typealias Load = (@escaping DismissInformer, @escaping (LoadFormResult<Confirmation>) -> Void) -> Void
        
        enum ConfirmationEvent {
            
            case dismissInformer
            case otp(String)
        }
        
        typealias ConfirmationNotify = (ConfirmationEvent) -> Void
        typealias LoadConfirmation = (@escaping ConfirmationNotify, @escaping (LoadConfirmationResult<Confirmation>) -> Void) -> Void
        
        typealias OrderCard = (OrderCardPayload, @escaping (OrderCardResult) -> Void) -> Void
        
        func handleEffect(
            _ effect: Effect,
            _ dispatch: @escaping Dispatch
        ) {
            switch effect {
            case .load:
                load({ dispatch(.dismissInformer) }) { dispatch(.loaded($0)) }
                
            case .loadConfirmation:
                
                let confirmationNotify: ConfirmationNotify = {
                    
                    switch $0 {
                    case .dismissInformer:
                        dispatch(.dismissInformer)
                        
                    case let .otp(otp):
                        dispatch(.otp(otp))
                    }
                }
                loadConfirmation(confirmationNotify) { dispatch(.loadConfirmation($0)) }
                
            case let .orderCard(payload):
                orderCard(payload) { dispatch(.orderCardResult($0)) }
            }
        }
        
        typealias Dispatch = (Event) -> Void
        typealias Event = Vortex.OrderCard.Event<Confirmation>
    }
}

private extension OrderCard.Reducer {
    
    func reduceContinue(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        guard let form = state.form else { return }
        
        switch form.confirmation {
        case .none:
            state.isLoading = true
            effect = .loadConfirmation
            
        case .some:
            if let payload = state.payload {
                
                state.isLoading = true
                effect = .orderCard(payload)
            }
        }
    }
    
    func reduceDismissInformer(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        if case let .failure(failure) = state.formResult,
           case .informer = failure.type {
            
            state.formResult = nil
        }
        
        if case let .failure(failure) = state.form?.confirmation,
           case .informer = failure.type {
            
            state.form?.confirmation = nil
        }
    }
}

extension OrderCard.State {
    
    var consent: Bool { form?.consent ?? false }
    
    var form: OrderCard.Form<Confirmation>? {
        
        get {
            
            guard case let .success(form) = formResult
            else { return nil }
            
            return form
        }
        
        set(newValue) {
            
            guard let newValue, case .success = formResult
            else { return }
            
            formResult = .success(newValue)
        }
    }
    
    var hasConfirmation: Bool {
        
        if case .success = form?.confirmation {
            return true
        } else {
            return false
        }
    }
    
    var isValid: Bool { form?.isValid ?? false } // rename to `canOrder`
    
    var payload: OrderCard.OrderCardPayload? {
        
        guard isValid,
              let form,
              let otp = form.otp
        else { return nil }
        
        return .init(
            requestID: form.requestID,
            cardApplicationCardType: form.cardApplicationCardType,
            cardProductExtID: form.cardProductExtID,
            cardProductName: form.cardProductName,
            smsInfo: form.messages.isOn,
            verificationCode: otp
        )
    }
}

extension OrderCard.Form {
    
    var isValid: Bool { otp?.count == 6 && consent } // rename to `canOrder`
}
