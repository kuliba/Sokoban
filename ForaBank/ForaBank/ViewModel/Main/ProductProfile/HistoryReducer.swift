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
                state = .init(
                    date: state?.date,
                    filters: state?.filters,
                    buttonAction: .calendar,
                    showSheet: true
                )
                
            case .filter:
                state = .init(
                    date: state?.date,
                    filters: state?.filters,
                    buttonAction: .filter,
                    showSheet: true
                )
            }
        case let .filter(filter):
            state = .init(
                date: state?.date,
                filters: filter,
                buttonAction: .filter,
                showSheet: false
            )
            
        case let .calendar(date):
            state = .init(
                date: date,
                filters: state?.filters,
                buttonAction: .calendar,
                showSheet: false
            )
        }
        
        return (state, effect)
    }
}

extension HistoryReducer {
    
    typealias Event = HistoryEvent
    typealias State = ProductProfileViewModel.HistoryState?
    typealias Effect = ProductProfileFlowEffect
}
