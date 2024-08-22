//
//  PaymentsTransfersToolbarReducer.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

final class PaymentsTransfersToolbarReducer<Profile, QR> {}

extension PaymentsTransfersToolbarReducer {
    
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

extension PaymentsTransfersToolbarReducer {
    
    typealias State = PaymentsTransfersToolbarState<Profile, QR>
    typealias Event = PaymentsTransfersToolbarEvent<Profile, QR>
    typealias Effect = PaymentsTransfersToolbarEffect
}

private extension PaymentsTransfersToolbarReducer {
    
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
