//
//  PaymentsTransfersFlowReducer.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public final class PaymentsTransfersFlowReducer<Profile, QR> {
    
    public init() {}
}

public extension PaymentsTransfersFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismiss:
            state.navigation = nil
            
        case let .open(open):
            handleOpen(&state, &effect, with: open)
            
        case let .profile(profile):
            state.navigation = .destination(.profile(profile))
            
        case let .qr(qr):
            state.navigation = .fullScreen(.qr(qr))
        }
        
        return (state, effect)
    }
}

public extension PaymentsTransfersFlowReducer {
    
    typealias State = PaymentsTransfersFlowState<Profile, QR>
    typealias Event = PaymentsTransfersFlowEvent<Profile, QR>
    typealias Effect = PaymentsTransfersFlowEffect
}

private extension PaymentsTransfersFlowReducer {
    
    func handleOpen(
        _ state: inout State,
        _ effect: inout Effect?,
        with open: Event.Open
    ) {
        guard state.navigation == nil else { return }
        
        switch open {
        case .profile:
            effect = .profile
            
        case .qr:
            effect = .qr
        }
    }
}
