//
//  PTCCTransfersSectionFlowReducer.swift
//  
//
//  Created by Igor Malyarov on 04.09.2024.
//

public final class PTCCTransfersSectionFlowReducer<Navigation, Select> {
    
    public init() {}
}

public extension PTCCTransfersSectionFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .navigation(navigation):
            state.navigation = navigation
            
        case let .select(select):
            effect = .select(select)
        }
        
        return (state, effect)
    }
}

public extension PTCCTransfersSectionFlowReducer {
    
    typealias State = PTCCTransfersSectionFlowState<Navigation>
    typealias Event = PTCCTransfersSectionFlowEvent<Navigation, Select>
    typealias Effect = PTCCTransfersSectionFlowEffect<Select>
}
