//
//  ExpandablePickerReducer.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

final class ExpandablePickerReducer<Item> {}

extension ExpandablePickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .select(selected):
            state.selection = selected
            state.toggle = .collapsed
            
        case .toggle:
            switch state.toggle {
            case .collapsed: state.toggle = .expanded
            case .expanded:  state.toggle = .collapsed
            }
        }
        
        return (state, nil)
    }
}

extension ExpandablePickerReducer {
    
    typealias State = ExpandablePickerState<Item>
    typealias Event = ExpandablePickerEvent<Item>
    typealias Effect = ExpandablePickerEffect
}

