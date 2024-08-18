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
        case .dismiss:
            state.navigation = .dismissed
            
        case .dismissDestination:
            state.navigation = nil
            
        case let .receiveScanResult(scanResult):
            effect = .processScanResult(scanResult)
            
        case let .setDestination(destination):
            state.navigation = .destination(destination)
        }
        
        return (state, effect)
    }
}

extension QRFlowReducer {
    
    typealias State = QRFlowState<Destination>
    typealias Event = QRFlowEvent<Destination, ScanResult>
    typealias Effect = QRFlowEffect<ScanResult>
}
