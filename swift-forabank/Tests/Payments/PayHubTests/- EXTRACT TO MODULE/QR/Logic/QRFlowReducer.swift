//
//  QRFlowReducer.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

final class QRFlowReducer<Destination, ScanResult> {}

extension QRFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .cancel:
            state.navigation = .cancel
            
        case let .destination(destination):
            state.navigation = .destination(destination)
        }
        
        return (state, effect)
    }
}

extension QRFlowReducer {
    
    typealias State = QRFlowState<Destination>
    typealias Event = QRFlowEvent<Destination>
    typealias Effect = QRFlowEffect<ScanResult>
}
