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
        case let .openSheet(category):
            fatalError()
        case .selectedPeriod(_):
            fatalError()
        case .selectedTransaction(_):
            fatalError()
        case .selectedCategory(_):
            fatalError()
        case let .selectedDates(range):
            
            state.filter.selectDates = range
            state.filter.selectedPeriod = .dates
            
            state.status = .loading
            effect = .updateFilter(.init(
                range: range,
                productId: state.productId
            ))
            
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
        }
        
        return (state, effect)
    }
}

//extract FilterModelEffectHandler to file

final class FilterModelEffectHandler {
    
    typealias MicroServices = FilterModelEffectHandlerMicroServices
    typealias Event = FilterEvent
    typealias Effect = FilterEffect
    typealias Dispatch = (Event) -> Void
    
    let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .updateFilter(range):
            microServices.updateFilter(range) {
                dispatch(.updateFilter($0))
            }
        }
    }
}

struct FilterModelEffectHandlerMicroServices {
    
    //TODO: replace `FilterState` with Result
    typealias UpdateFilterCompletion = (FilterState?) -> Void
    typealias UpdateFilter = (FilterEffect.UpdateFilterPayload, @escaping UpdateFilterCompletion) -> Void
    
    let updateFilter: UpdateFilter
}
