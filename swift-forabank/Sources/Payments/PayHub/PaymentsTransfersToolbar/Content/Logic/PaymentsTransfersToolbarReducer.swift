//
//  PaymentsTransfersToolbarReducer.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public final class PaymentsTransfersToolbarReducer {
    
    public init() {}
}

public extension PaymentsTransfersToolbarReducer {
    
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

public extension PaymentsTransfersToolbarReducer {
    
    typealias State = PaymentsTransfersToolbarState
    typealias Event = PaymentsTransfersToolbarEvent
    typealias Effect = PaymentsTransfersToolbarEffect
}

private extension PaymentsTransfersToolbarReducer {
    
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
