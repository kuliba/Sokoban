//
//  ProductPickerReducer.swift
//  
//
//  Created by Igor Malyarov on 21.04.2024.
//

final class ProductPickerReducer {}

extension ProductPickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        //        switch event {
        //
        //        }
        
        return (state, effect)
    }
}

extension ProductPickerReducer {
    
    typealias State = ProductPickerState
    typealias Event = ProductPickerEvent
    typealias Effect = Never
}
