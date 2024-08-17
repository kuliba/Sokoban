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
            state.destination = nil
            
        case .open(.profile):
            effect = .profile
            
        case .open(.qr):
            effect = .qr
            
        case let .profile(profile):
            state.destination = .profile(profile)
            
        case let .qr(qr):
            state.destination = .qr(qr)
        }
        
        return (state, effect)
    }
}

public extension PaymentsTransfersFlowReducer {
    
    typealias State = PaymentsTransfersFlowState<Profile, QR>
    typealias Event = PaymentsTransfersFlowEvent<Profile, QR>
    typealias Effect = PaymentsTransfersFlowEffect
}
