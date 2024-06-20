//
//  HistoryReducer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 20.06.2024.
//

import Foundation

final class HistoryReducer {}

extension HistoryReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .button(event):
            switch event {
            case .calendar:
                state = .calendar
                
            case .filter:
                state = .filter
            }
        }
        return (state, effect)
    }
}

extension HistoryReducer {
    
    typealias Event = HistoryEvent
    typealias State = HistoryState?
    typealias Effect = ProductNavigationStateEffect
}
