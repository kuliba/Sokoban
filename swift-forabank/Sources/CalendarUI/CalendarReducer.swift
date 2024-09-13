//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 11.09.2024.
//

import Foundation
#warning("add tests")
public final class CalendarReducer {}

public extension CalendarReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .activateContract:
            (state, effect) = activateContract(state)
            
        case .deactivateContract:
            (state, effect) = deactivateContract(state)
            
        case let .updateContract(result):
            state = updateContract(state, with: result)
        }
        
        return (state, effect)
    }
}
