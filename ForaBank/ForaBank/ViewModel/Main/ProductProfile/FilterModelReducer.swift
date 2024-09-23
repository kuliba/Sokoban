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
                state.filter.selectDates = (.startOfWeek ?? Date())..<Date()
            case .month:
                state.filter.selectDates = (.startOfMonth)..<(Date())
            case .dates:
                break
            }
        case let .selectedTransaction(transactionType):
            state.filter.selectedTransaction = transactionType
            
        case let .selectedCategory(service):
            
            if state.filter.selectedServices.contains(service) {
                
                state.filter.selectedServices.remove(service)
            } else {
                state.filter.selectedServices.insert(service)
            }
            
        case let .selectedDates(range):
            
            if state.filter.selectDates != range {
                
            state.filter.selectDates = range
            state.filter.selectedPeriod = .dates
            
                state.status = .loading
                effect = .updateFilter(.init(
                    range: range.lowerBound.addingTimeInterval(10800)..<range.upperBound.addingTimeInterval(10800),
                    productId: state.productId
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
            state.filter.selectedServices = []
            state.filter.selectedPeriod = .month
            state.filter.selectedTransaction = nil
            effect = .resetPeriod(state.productId)
        }
        
        return (state, effect)
    }
}
