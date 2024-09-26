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
        var effect: Effect?
        
        switch event {
        case let .resetPeriod(range):
            state.filter.selectDates = range
    
        case let .selectedPeriod(period):
            switch period {
            case .week:
                state.filter.selectedPeriod = .week
                state.filter.selectDates = (.startOfWeek ?? Date())..<Date()
                state.status = .loading
            case .month:
                state.filter.selectedPeriod = .month
                state.filter.selectDates = (.startOfMonth)..<(Date())
                state.status = .loading
            case .dates:
                state.filter.selectedPeriod = .dates
            }
        case let .selectedTransaction(transactionType):
            state.filter.selectedTransaction = transactionType
            
        case let .selectedCategory(service):
            
            if state.filter.selectedServices.contains(service) {
                
                state.filter.selectedServices.remove(service)
            } else {
                state.filter.selectedServices.insert(service)
            }
            
        case let .selectedDates(range, period):
            
            if state.filter.selectDates != range {
                
                state.filter.selectDates = range
                state.filter.selectedPeriod = period
                
                state.status = .loading
                effect = .updateFilter(.init(
                    range: range,
                    productId: state.productId,
                    selectPeriod: period
                ))
            }
            
        case .updateFilter(nil):
            state.status = .failure
            
        case let .updateFilter(.some(newState)):
            if newState.filter.services.isEmpty {
                
                state.status = .empty
            } else {
            
                state.status = .normal
            }
            
            state = newState

        case .clearOptions:
            state.calendar.range = .init()
            state.filter.selectedServices = []
            state.filter.selectedPeriod = .month
            state.filter.selectedTransaction = nil
            effect = .resetPeriod(state.productId)
        }
        
        return (state, effect)
    }
}
