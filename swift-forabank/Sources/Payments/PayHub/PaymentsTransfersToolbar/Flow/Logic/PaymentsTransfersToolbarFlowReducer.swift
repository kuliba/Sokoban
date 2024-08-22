//
//  PaymentsTransfersToolbarFlowReducer.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public final class PaymentsTransfersToolbarFlowReducer<Profile, QR> {
    
    public init() {}
}

public extension PaymentsTransfersToolbarFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismiss:
            state.navigation = nil
            
        case let .profile(profile):
            state.navigation = .profile(profile)
            
        case let .qr(qr):
            state.navigation = .qr(qr)
            
        case let .select(select):
            self.select(&state, &effect, with: select)
        }
        
        return (state, effect)
    }
}

public extension PaymentsTransfersToolbarFlowReducer {
    
    typealias State = PaymentsTransfersToolbarFlowState<Profile, QR>
    typealias Event = PaymentsTransfersToolbarFlowEvent<Profile, QR>
    typealias Effect = PaymentsTransfersToolbarFlowEffect
}

private extension PaymentsTransfersToolbarFlowReducer {
    
    func select(
        _ state: inout State,
        _ effect: inout Effect?,
        with select: Event.Select
    ) {
        state.navigation = nil
        
        switch select {
        case .profile:
            effect = .select(.profile)
            
        case .qr:
            effect = .select(.qr)
        }
    }
}
