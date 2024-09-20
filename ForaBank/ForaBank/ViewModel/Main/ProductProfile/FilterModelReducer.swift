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
                    range: range,
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
        case let .resetPeriod(productId):
            microServices.resetPeriod(productId) {
                dispatch(.resetPeriod($0))
            }
            
        case let .updateFilter(range):
            microServices.updateFilter(range) {
                dispatch(.updateFilter($0))
            }
        }
    }
}

struct FilterModelEffectHandlerMicroServices {
    
    typealias ResetPeriodCompletion = (Range<Date>) -> Void
    typealias ResetPeriod = (ProductData.ID, @escaping ResetPeriodCompletion) -> Void
    
    //TODO: replace `FilterState` with Result
    typealias UpdateFilterCompletion = (FilterState?) -> Void
    typealias UpdateFilter = (FilterEffect.UpdateFilterPayload, @escaping UpdateFilterCompletion) -> Void
    
    let resetPeriod: ResetPeriod
    let updateFilter: UpdateFilter
}
