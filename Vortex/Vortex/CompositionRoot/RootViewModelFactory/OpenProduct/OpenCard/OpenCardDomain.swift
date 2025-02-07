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
    
    typealias LoadResult = OrderCard.LoadResult<Confirmation>
    typealias LoadFailure = OrderCard.LoadFailure
    
    typealias OrderCardPayload = OrderCard.OrderCardPayload
    typealias OrderCardResult = OrderCard.OrderCardResult
}

enum OrderCard { // TODO: replace stub with types from module
    
    struct State<Confirmation> {
        
        var isLoading: Bool = false
#warning("move into form")
        var otp: String?
        var consent = true
        var orderCardResult: OrderCardResult?
        var result: LoadResult<Confirmation>?
    }
    
    struct Form<Confirmation> {
        
        var confirmation: LoadConfirmationResult<Confirmation>?
        let product: Int // Product
        let type: String //ProductType
        var messages: Messages
        
        struct Messages: Equatable {
            
            let description: String
            let icon: String
            let subtitle: String
            let title: String
            var isOn: Bool
        }
    }
    
    typealias LoadResult<Confirmation> = Result<Form<Confirmation>, LoadFailure>
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
        case loaded(LoadResult<Confirmation>)
        case loadConfirmation(LoadConfirmationResult<Confirmation>)
        case messages(MessagesEvent)
        case orderCardResult(OrderCardResult)
        case otp(String)
        case setConsent(Bool)
        
        public enum MessagesEvent: Equatable {
            
            case toggle
        }
    }
    
    enum Effect: Equatable {
        
        case load
        case loadConfirmation
        case orderCard(OrderCardPayload)
    }
    
    struct OrderCardPayload: Equatable {}
    
    typealias OrderCardResult = Bool // TODO: improve associated value
    
    final class Reducer<Confirmation> {
        
        init() {}
        
        func reduce(
            _ state: State,
            _ event: Event
        ) -> (State, Effect?) {
            
            var state = state
            var effect: Effect?
            
            switch event {
            case .continue:
                switch state.result {
                case .none, .failure:
                    break
                    
                case let .success(form):
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
                
            case .dismissInformer:
                if case let .failure(failure) = state.result,
                   case .informer = failure.type {
                    
                    state.result = nil
                }
                
                if case var .success(form) = state.result,
                   case let .failure(failure) = form.confirmation,
                   case .informer = failure.type {
                    
                    form.confirmation = nil
                    state.result = .success(form)
                }
                
            case .load:
                state.isLoading = true
                effect = .load
                
            case let .loadConfirmation(confirmation):
                state.isLoading = false
                
                switch (state.result, confirmation) {
                case (.none, _), (.failure, _):
                    break // impossible cases
                    
                case (var .success(form), let confirmation):
                    form.confirmation = confirmation
                    state.result = .success(form)
                }
                
            case let .loaded(result):
                state.isLoading = false
                state.result = result
                
            case .messages(.toggle):
                switch (state.result, state.isLoading) {
                case var (.success(form), false):
                    form.messages.isOn.toggle()
                    state.result = .success(form)
                    
                default: break
                }
                
            case let .orderCardResult(orderCardResult):
                state.orderCardResult = orderCardResult
                
            case let .otp(otp):
                if case let .success(form) = state.result,
                   case .success = form.confirmation {
                    
                    state.otp = otp
                }
                
            case let .setConsent(consent):
                if case let .success(form) = state.result,
                   case .success = form.confirmation {
                    
                    state.consent = consent
                }
            }
            
            return (state, effect)
        }
        
        typealias State = OrderCard.State<Confirmation>
        typealias Event = OrderCard.Event<Confirmation>
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
        typealias Load = (@escaping DismissInformer, @escaping (LoadResult<Confirmation>) -> Void) -> Void
        
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

extension OrderCard.State {
    
    var isValid: Bool { payload != nil }
    
    var payload: OrderCard.OrderCardPayload? {
        
        guard otp?.count == 6,
              consent
        else { return nil }
        
        return .init()
    }
}
