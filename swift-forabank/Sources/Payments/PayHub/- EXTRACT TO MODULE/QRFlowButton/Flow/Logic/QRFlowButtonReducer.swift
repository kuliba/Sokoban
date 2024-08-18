//
//  QRFlowButtonReducer.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

public final class QRFlowButtonReducer<Destination> {
    
    public init() {}
}

public extension QRFlowButtonReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .buttonTap:
            effect = .processButtonTap
            
        case let .setDestination(destination):
            state.destination = destination
        }
        
        return (state, effect)
    }
}

public extension QRFlowButtonReducer {
    
    typealias State = QRFlowButtonState<Destination>
    typealias Event = QRFlowButtonEvent<Destination>
    typealias Effect = QRFlowButtonEffect
}
