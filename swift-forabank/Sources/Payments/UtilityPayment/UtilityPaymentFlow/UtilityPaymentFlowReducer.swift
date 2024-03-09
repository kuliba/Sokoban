//
//  UtilityPaymentFlowReducer.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import PrePaymentPicker

public final class UtilityPaymentFlowReducer<LastPayment, Operator, Response>
where Operator: Identifiable {
    
    private let prePaymentOptionsReduce: PrePaymentOptionsReduce
    private let prePaymentReduce: PrePaymentReduce
    
    public init(
        prePaymentOptionsReduce: @escaping PrePaymentOptionsReduce,
        prePaymentReduce: @escaping PrePaymentReduce
    ) {
        self.prePaymentOptionsReduce = prePaymentOptionsReduce
        self.prePaymentReduce = prePaymentReduce
    }
}

public extension UtilityPaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
#warning("add state to switch do exclude impossible cases (?)")
        switch event {
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
    
    typealias PPState = PrePaymentState<LastPayment, Operator>
    typealias PPEvent = PrePaymentEvent<LastPayment, Operator, Response>
    typealias PPEffect = PrePaymentEffect<LastPayment, Operator>
    typealias PrePaymentReduce = (PPState, PPEvent) -> (PPState, PPEffect?)
    
    typealias State = UtilityPaymentFlowState<LastPayment, Operator>
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, Response>
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator>
}

private extension UtilityPaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: PPOEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.current {
        case let .prePaymentOptions(prePaymentOptionsState):
            let (ppoState, ppoEffect) = prePaymentOptionsReduce(prePaymentOptionsState, event)
            
            if ppoState.isInflight {
                state.isInflight = true
            }
            state.current = .prePaymentOptions(ppoState)
            effect = ppoEffect.map { Effect.prePaymentOptions($0) }
            
        default:
            break
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
            case .addCompany:
                state.current = .prePaymentState(.addingCompany)
                
            case .back:
                state.current = nil
                
            case .payByInstruction:
                state.current = .prePaymentState(.payingByInstruction)
                
            case .scan:
                state.current = .prePaymentState(.scanning)
                
            case let .select(select):
                state.isInflight = true
                effect = .prePayment(startPayment(select))
                
            case let .paymentStarted(result):
                fatalError("can't handle `paymentStarted` event with \(result)")
            }
            
        case let .prePaymentState(prePaymentState):
            switch event {
            case .addCompany, .payByInstruction, .scan:
                break
                
            case .back:
                switch prePaymentState {
                case .addingCompany:
                    break
                    
                case .payingByInstruction, .scanning:
                    state.pop()
                    
                case let .selected(selected):
                    fatalError("can't handle `selected(\(selected))` event \(event) on prePaymentState state \(prePaymentState)")
                    
                case .selecting:
                    fatalError("can't handle event \(event) on prePaymentState state \(prePaymentState)")
                }
                
            case .select:
                break
                
            case let .paymentStarted(result):
                fatalError("can't handle `paymentStarted` event with \(result)")
            }
        }
        
        return (state, effect)
    }
    
    func startPayment(
        _ event: PPEvent.SelectEvent
    ) -> PPEffect {
        
        switch event {
        case let .last(lastPayment):
            return .startPayment(.last(lastPayment))
            
        case let .operator(`operator`):
            return .startPayment(.operator(`operator`))
        }
    }
}
