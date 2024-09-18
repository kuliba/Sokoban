//
//  FilterModelReducer.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 18.09.2024.
//

import Foundation
import CalendarUI

final class FilterModelReducer {
    
    typealias State = FilterState
    typealias Event = FilterEvent
    typealias Effect = FilterEffect
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .openSheet(category):
            fatalError()
        case .selectedPeriod(_):
            fatalError()
        case .selectedTransaction(_):
            fatalError()
        case .selectedCategory(_):
            fatalError()
        case .selectedDates(lowerDate: let lowerDate, upperDate: let upperDate):
            fatalError()
        case let .updateFilter(newState):
            state = newState
        case .clearOptions:
            state.filter.selectedServices = []
            state.filter.selectedPeriod = .month
            state.filter.selectedTransaction = nil
        }
        
        return (state, nil)
    }
}

//extract FilterModelEffectHandler to file

final class FilterModelEffectHandler {
    
    typealias Event = FilterEvent
    typealias Effect = FilterEffect
    typealias Dispatch = (Event) -> Void
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
        switch effect {}
    }
}
