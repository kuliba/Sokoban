//
//  UtilityPaymentReducer.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class UtilityPaymentReducer {
    
    private let prePaymentReduce: PrePaymentReduce
    
    public init(
        prePaymentReduce: @escaping PrePaymentReduce
    ) {
        self.prePaymentReduce = prePaymentReduce
    }
}

public extension UtilityPaymentReducer {
    
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

public extension UtilityPaymentReducer {
    
    typealias PrePaymentReduce = (PrePaymentState, PrePaymentEvent) -> (PrePaymentState, PrePaymentEffect?)
    
    typealias State = UtilityPaymentState
    typealias Event = UtilityPaymentEvent
    typealias Effect = UtilityPaymentEffect
}

private extension UtilityPaymentReducer {
    
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
