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
        
        var result: LoadResult<Confirmation>?
    }
    
    struct Form<Confirmation> {
        
        var confirmation: LoadConfirmationResult<Confirmation>?
        let product: Int // Product
        let type: String //ProductType
        var messages: Bool // SMS
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
        case load
        case loaded(LoadResult<Confirmation>)
        case loadConfirmation(LoadConfirmationResult<Confirmation>)
        case messages(MessagesEvent)
        case orderCardResult(Bool)
        
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
    
    typealias OrderCardResult = Bool
    
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
                        // TODO: change state to inflight/isLoading
                        effect = .loadConfirmation
                        
                    case .some:
                        // TODO: change state to inflight/isLoading
                        effect = .orderCard(.init())
                    }
                }
                
            case .load:
                effect = .load
                
            case let .loadConfirmation(confirmation):
                switch (state.result, confirmation) {
                case (.none, _), (.failure, _):
                    break // impossible cases
                    
                case var (.success(form), confirmationResult):
                    form.confirmation = confirmationResult
                    state.result = .success(form)
                    
                }
            case let .loaded(result):
                state.result = result
                
            case let .messages(value):
                break // TODO: ignoring here but should not in real type
                
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
        
        typealias Load = (@escaping (LoadResult<Confirmation>) -> Void) -> Void
        typealias LoadConfirmation = (@escaping (LoadConfirmationResult<Confirmation>) -> Void) -> Void
        typealias OrderCard = (OrderCardPayload, @escaping (Bool) -> Void) -> Void
        
        func handleEffect(
            _ effect: Effect,
            _ dispatch: @escaping Dispatch
        ) {
            switch effect {
            case .load:
                load { dispatch(.loaded($0)) }
                
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
