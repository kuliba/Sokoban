//
//  CalendarReducer.swift
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
        case let .selectedDate(date):
            state = .init(
                date: state.date,
                range: .init(date, date),
                monthsData: state.monthsData,
                periods: state.periods
            )
        case let .selectPeriod(period, lowerDate, upperDate):
            state = .init(
                date: state.date,
                range: .init(lowerDate, upperDate),
                monthsData: state.monthsData,
                selectPeriod: period,
                periods: state.periods
            )
        case .selectCustomPeriod:
            break
        }
        
        return (state, effect)
    }
}

public extension CalendarReducer {
    
    typealias State = CalendarState
    typealias Event = CalendarEvent
    typealias Effect = CalendarEffect
}

public struct CalendarEffect {}
