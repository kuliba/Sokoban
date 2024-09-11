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
            case let .calendar(applyAction):
                state = .init(
                    date: state?.date,
                    filters: state?.filters,
                    selectedDates: (lowerDate: nil, upperDate: nil),
                    buttonAction: .calendar,
                    showSheet: true,
                    categories: state?.categories ?? [],
                    applyAction: applyAction
                )
                
            case let .filter(lowerDate, upperDate):
                state = .init(
                    date: state?.date,
                    filters: state?.filters,
                    selectedDates: (lowerDate: lowerDate, upperDate: upperDate),
                    buttonAction: .filter,
                    showSheet: true,
                    categories: state?.categories ?? [],
                    applyAction: {lowerDate,upperDate in
                    
                        
                    }
                )
            }
        case let .filter(filter):
            state = .init(
                date: state?.date,
                filters: filter,
                selectedDates: (lowerDate: nil, upperDate: nil),
                buttonAction: .filter,
                showSheet: false,
                categories: state?.categories ?? [],
                applyAction: {lowerDate,upperDate in }

            )
            
        case let .calendar(date):
            state = .init(
                date: date,
                filters: state?.filters,
                selectedDates: (lowerDate: nil, upperDate: nil),
                buttonAction: .calendar,
                showSheet: false,
                categories: state?.categories ?? [],
                applyAction: {lowerDate,upperDate in }
            )
        
        case .clearOptions:
            state = nil
            
        case .dismiss:
            state = nil
        }
        
        return (state, effect)
    }
}

extension HistoryReducer {
    
    typealias Event = HistoryEvent
    typealias State = ProductProfileViewModel.HistoryState?
    typealias Effect = ProductProfileFlowEffect
}
