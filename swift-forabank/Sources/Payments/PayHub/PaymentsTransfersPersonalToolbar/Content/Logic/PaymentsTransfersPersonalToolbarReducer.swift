//
//  PaymentsTransfersPersonalToolbarReducer.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public final class PaymentsTransfersPersonalToolbarReducer {
    
    public init() {}
}

public extension PaymentsTransfersPersonalToolbarReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .select(select):
            self.select(&state, &effect, with: select)
        }
        
        return (state, effect)
    }
}

public extension PaymentsTransfersPersonalToolbarReducer {
    
    typealias State = PaymentsTransfersPersonalToolbarState
    typealias Event = PaymentsTransfersPersonalToolbarEvent
    typealias Effect = PaymentsTransfersPersonalToolbarEffect
}

private extension PaymentsTransfersPersonalToolbarReducer {
    
    func select(
        _ state: inout State,
        _ effect: inout Effect?,
        with select: Event.Select?
    ) {
        switch select {
        case .none:
            state.selection = nil
            
        case .profile:
            state.selection = .profile
            
        case .qr:
            state.selection = .qr
        }
    }
}
