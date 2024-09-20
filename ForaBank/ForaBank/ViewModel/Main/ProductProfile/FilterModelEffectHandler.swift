//
//  FilterModelEffectHandler.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 20.09.2024.
//

import Foundation
import CalendarUI

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
        case let .resetPeriod(productId, state):
            microServices.resetPeriod(productId) { period in
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    dispatch(.resetPeriod(period))
                }
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
