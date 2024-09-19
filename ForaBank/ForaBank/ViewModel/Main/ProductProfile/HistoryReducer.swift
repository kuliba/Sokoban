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
                    showSheet: .calendar,
                    categories: state?.categories ?? [],
                    applyAction: applyAction,
                    calendarState: nil
                )
                
            case let .filter(productId, lowerDate, upperDate):
                effect = .filter(
                    productId: productId,
                    lowerDate: lowerDate,
                    upperDate: upperDate,
                    selectServices: .init(state?.categories ?? [])
                )
//                state = .init(
//                    date: state?.date,
//                    filters: state?.filters,
//                    selectedDates: (lowerDate: lowerDate, upperDate: upperDate),
//                    buttonAction: .filter,
//                    showSheet: .filter,
//                    categories: state?.categories ?? [],
//                    applyAction: {lowerDate,upperDate in
//                        
//                    },
//                    calendarState: nil
//                )
            }
        case let .receive(filterModel):
            state = .init(
                date: state?.date,
                filters: state?.filters,
                selectedDates: (lowerDate: filterModel.state.calendar.range?.lowerDate, upperDate: filterModel.state.calendar.range?.upperDate),
                buttonAction: .filter,
                showSheet: .filter(filterModel),
                categories: state?.categories ?? [],
                applyAction: {lowerDate,upperDate in
                    
                },
                calendarState: nil
            )
            
        case let .filter(event):
            switch event {
            case let .calendar(event):
                switch event {
                case .selectCustomPeriod:
                    break
                case let .selectPeriod(period, lowerDate: lowerDate, upperDate: upperDate):
                    state?.selectedDates = (lowerDate, upperDate)
                    state?.calendarState = nil
                case let .selectedDate(date):
                    break
                }
                
            case let .period(calendarState):
                state?.calendarState = .init(state: calendarState)
                
            case .dismissCalendar:
                state?.calendarState = nil
            }
            
        case let .calendar(date):
            state = .init(
                date: date,
                filters: state?.filters,
                selectedDates: (lowerDate: nil, upperDate: nil),
                buttonAction: .calendar,
                showSheet: .calendar,
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
    typealias Effect = HistoryEffect
}

enum HistoryEffect {
    
    case filter(productId: ProductData.ID, lowerDate: Date?, upperDate: Date?, selectServices: Set<String>)
}
