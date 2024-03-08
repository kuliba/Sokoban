//
//  UtilityPaymentFlowReducer.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

import PrePaymentPicker

public final class UtilityPaymentFlowReducer<LastPayment, Operator> 
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
            
        case let .prePayment(prePaymentEvent):
            (state, effect) = reduce(state, prePaymentEvent)
        }
        
        return (state, effect)
    }
}

public extension UtilityPaymentFlowReducer {
    
    typealias PrePaymentOptionsReduce = (PrePaymentOptionsState<LastPayment, Operator>, PrePaymentOptionsEvent<LastPayment, Operator>) -> (PrePaymentOptionsState<LastPayment, Operator>, PrePaymentOptionsEffect<Operator>?)
    typealias PrePaymentReduce = (PrePaymentState, PrePaymentEvent) -> (PrePaymentState, PrePaymentEffect?)
    
    typealias State = UtilityPaymentFlowState<LastPayment, Operator>
    typealias Event = UtilityPaymentFlowEvent
    typealias Effect = UtilityPaymentFlowEffect
}

private extension UtilityPaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: PrePaymentEvent
    ) -> (State, Effect?) {
        
        fatalError()
//        var state = state
//        var effect: Effect?
//        
//        switch state.prePayment {
//        case .none:
//            break
//            
//        case let .some(prePaymentState):
//            let (prePaymentState, _) = prePaymentReduce(prePaymentState, event)
//            
//            switch prePaymentState {
//            case .addingCompany:
//                <#code#>
//
//            case .payingByInstruction:
//                <#code#>
//
//            case .scanning:
//                <#code#>
//
//            case let .selected(selected):
//                <#code#>
//
//            case .selecting:
//                <#code#>
//            }
//        }
//
//        return (state, effect)
    }
}
