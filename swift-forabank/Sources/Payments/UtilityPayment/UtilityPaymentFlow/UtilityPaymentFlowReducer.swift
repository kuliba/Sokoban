//
//  UtilityPaymentFlowReducer.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import PrePaymentPicker

public final class UtilityPaymentFlowReducer<LastPayment, Operator, Response, Service>
where Operator: Identifiable {
    
    private let prePaymentOptionsReduce: PrePaymentOptionsReduce
    
    public init(
        prePaymentOptionsReduce: @escaping PrePaymentOptionsReduce
    ) {
        self.prePaymentOptionsReduce = prePaymentOptionsReduce
    }
}

public extension UtilityPaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .back:
            switch state.status {
            case .failure:
                break
                
            default:
                state.current = nil
            }
            
        case let .prePaymentOptions(prePaymentOptionsEvent):
            (state, effect) = reduce(state, prePaymentOptionsEvent)
            
        case let .prePayment(prePaymentEvent):
            (state, effect) = reduce(state, prePaymentEvent)
        }
        
        return (state, effect)
    }
}

public extension UtilityPaymentFlowReducer {
    
    typealias PPOState = PrePaymentOptionsState<LastPayment, Operator>
    typealias PPOEvent = PrePaymentOptionsEvent<LastPayment, Operator>
    typealias PPOEffect = PrePaymentOptionsEffect<Operator>
    typealias PrePaymentOptionsReduce = (PPOState, PPOEvent) -> (PPOState, PPOEffect?)
    
    typealias PPState = PrePaymentState<LastPayment, Operator, Service>
    typealias PPEvent = PrePaymentEvent<LastPayment, Operator, Response, Service>
    typealias PPEffect = PrePaymentEffect<LastPayment, Operator, Service>
    
    typealias State = UtilityPaymentFlowState<LastPayment, Operator, Service>
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, Response, Service>
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, Service>
}

private extension UtilityPaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: PPOEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.current {
        case .none:
            switch event {
            case let .loaded(loadLastPaymentsResult, loadOperatorsResult):
                state.isInflight = false
                state.current = .prePaymentOptions(.init(
                    lastPayments: try? loadLastPaymentsResult.get(),
                    operators: try? loadOperatorsResult.get()
                ))
                
            case .initiate:
                let (ppoState, ppoEffect) = prePaymentOptionsReduce(.init(), event)
                if ppoState.isInflight {
                    state.status = .inflight
                } else {
                    state.status = .none
                }
                state.current = .prePaymentOptions(ppoState)
                effect = ppoEffect.map { .prePaymentOptions($0) }
                
            default:
                break
            }
            
        case let .prePaymentOptions(prePaymentOptionsState):
            let (ppoState, ppoEffect) = prePaymentOptionsReduce(prePaymentOptionsState, event)
            
            if ppoState.isInflight {
                state.status = .inflight
            } else {
                state.status = .none
            }
            state.current = .prePaymentOptions(ppoState)
            effect = ppoEffect.map { .prePaymentOptions($0) }
            
        case .prePaymentState:
            break
            
        case .payment:
            fatalError()
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: PPEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.current {
        case .none:
            fatalError("can't handle empty flow stack")
            
        case .prePaymentOptions:
            
            switch event {
            case let .loaded(result):
                state.status = nil
                
                switch result {
                case .failure:
                    state.push(.prePaymentState(.payingByInstruction))
                    
                case let .list(services):
                    // `services` is array thus there is no guaranty that it contains many
                    switch services.count {
                    case 0, 1:
                        state.push(.prePaymentState(.payingByInstruction))
                        
                    default:
                        state.push(.prePaymentState(.services(services)))
                    }
                }
                
            case .payByInstruction:
                state.push(.prePaymentState(.payingByInstruction))
                
            case .scan:
                state.push(.prePaymentState(.scanning))
                
            case let .select(select):
                state.isInflight = true
                effect = .prePayment(handleSelect(select))
                
            case let .paymentStarted(result):
                switch result {
                case let .failure(serviceFailure):
                    state.status = .failure(serviceFailure)
                    
                case let .success(response):
                    state.status = nil
                    state.push(.payment)
                }
            }
            
        case let .prePaymentState(prePaymentState):
            switch event {
            case .payByInstruction, .scan:
                break
                
            case let .loaded(result):
                fatalError("can't handle `loaded` event with \(result)")
                
            case let .select(select):
                switch prePaymentState {
                case .services:
                    state.isInflight = true
                    effect = .prePayment(handleSelect(select))
                    
                default:
                    break
                }

            case let .paymentStarted(result):
                switch result {
                case let .failure(serviceFailure):
                    state.status = .failure(serviceFailure)
                    
                case let .success(response):
                    state.status = nil
                    state.push(.payment)
                }
            }
            
        case .payment:
            fatalError()
        }
        
        return (state, effect)
    }
    
    func handleSelect(
        _ event: PPEvent.SelectEvent
    ) -> PPEffect {
        
        switch event {
        case let .last(lastPayment):
            return .select(.last(lastPayment))
            
        case let .operator(`operator`):
            return .select(.operator(`operator`))
            
            #warning("move `operator` to state, selection should be performed using service only")
        case let .service(`operator`, service):
            return .select(.service(`operator`, service))
        }
    }
}
