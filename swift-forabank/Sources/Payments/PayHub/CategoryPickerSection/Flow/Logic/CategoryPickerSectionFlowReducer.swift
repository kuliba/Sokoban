//
//  CategoryPickerSectionFlowReducer.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public final class CategoryPickerSectionFlowReducer<Select, Navigation> {
    
    public init() {}
}

public extension CategoryPickerSectionFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.isLoading = false
        
        switch event {
        case .dismiss:
            state.navigation = nil
            
        case let .receive(navigation):
            state.navigation = navigation
            
        case let .select(select):
            state.isLoading = true
            state.navigation = nil
            effect = .select(select)
        }
        
        return (state, effect)
    }
}

public extension CategoryPickerSectionFlowReducer {
    
    typealias State = CategoryPickerSectionFlowState<Navigation>
    typealias Event = CategoryPickerSectionFlowEvent<Select, Navigation>
    typealias Effect = CategoryPickerSectionFlowEffect<Select>
}
