//
//  ExpandablePickerViewModel+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

extension ExpandablePickerViewModel {
    
    static var preview: ExpandablePickerViewModel<String> {
        
        let reducer = ExpandablePickerReducer<String>()
        
        return .init(
            initialState: .preview,
            reduce: reducer.reduce,
            handleEffect: { _,_ in }
        )
    }
    
    static func decorated(
        _ onSelect: @escaping (String) -> Void
    ) -> ExpandablePickerViewModel<String> {
        
        decorated(
            initialState: .preview,
            with: { event, state in
                
                guard case .select = event else { return }
                
                onSelect(state.selection)
            }
        )
    }
    
    static func decorated<T>(
        initialState: ExpandablePickerState<T>,
        with action: @escaping (ExpandablePickerEvent<T>, ExpandablePickerState<T>) -> Void
    ) -> ExpandablePickerViewModel<T> {
        
        let reducer = ExpandablePickerReducer<T>()
        
        return .init(
            initialState: initialState,
            reduce: { state, event in
                
                let (state, effect): (ExpandablePickerState, ExpandablePickerEffect?) = reducer.reduce(state, event)
                action(event, state)
                
                return (state, effect)
            },
            handleEffect: { _,_ in }
        )
    }
}
