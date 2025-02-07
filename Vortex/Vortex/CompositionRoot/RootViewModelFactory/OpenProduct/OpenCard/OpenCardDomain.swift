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
                        // TODO: verify otp by creating `OrderCardPayload` (should have failable init)
                        if let payload: OrderCardPayload? = OrderCardPayload() {
                         
                            state.isLoading = true
                            effect = payload.map { .orderCard($0) }
                        }
                    }
                }
                
            case .dismissInformer:
                if case let .failure(failure) = state.result,
                   case .informer = failure.type {
                    
                    state.result = nil
                }
                
            case .load:
                state.isLoading = true
                effect = .load
                
            case let .loadConfirmation(confirmation):
                state.isLoading = false
                
                switch (state.result, confirmation) {
                case (.none, _), (.failure, _):
                    break // impossible cases
                    
                case var (.success(form), confirmation):
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
#warning("UNIMPLEMENTED")
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
        
        typealias Load = (@escaping () -> Void, @escaping (LoadResult<Confirmation>) -> Void) -> Void
        typealias LoadConfirmation = (@escaping (LoadConfirmationResult<Confirmation>) -> Void) -> Void
        typealias OrderCard = (OrderCardPayload, @escaping (OrderCardResult) -> Void) -> Void
        
        func handleEffect(
            _ effect: Effect,
            _ dispatch: @escaping Dispatch
        ) {
            switch effect {
            case .load:
                load({ dispatch(.dismissInformer) }) { dispatch(.loaded($0)) }
                
            case .loadConfirmation:
                loadConfirmation { dispatch(.loadConfirmation($0)) }
                
            case let .orderCard(payload):
                orderCard(payload) { dispatch(.orderCardResult($0)) }
            }
        }
        
        typealias Dispatch = (Event) -> Void
        typealias Event = Vortex.OrderCard.Event<Confirmation>
    }
}
