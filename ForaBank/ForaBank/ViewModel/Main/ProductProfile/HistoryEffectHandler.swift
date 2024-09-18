//
//  HistoryEffectHandler.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 18.09.2024.
//

import Foundation
import CalendarUI

struct HistoryEffectHandlerMicroServices {
    
    struct MakeFilterModelPayload: Equatable {
        
        let productId: ProductData.ID
        let lowerDate: Date?
        let upperDate: Date?
        let selectedServices: Set<String>
    }
    
    typealias MakeFilterModelCompletion = (FilterWrapperView.Model) -> Void
    typealias MakeFilterModel = (MakeFilterModelPayload, @escaping MakeFilterModelCompletion) -> Void
    
    let makeFilterModel: MakeFilterModel
}

final class HistoryEffectHandler {
    
    typealias MicroServices = HistoryEffectHandlerMicroServices
    
    private let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
}

extension HistoryEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .filter(productId: productId, lowerDate: lowerDate, upperDate: upperDate, selectServices):
            
            microServices.makeFilterModel(.init(
                productId: productId,
                lowerDate: lowerDate,
                upperDate: upperDate,
                selectedServices: selectServices
            )) {
                dispatch(.receive($0))
            }
        }
    }
}

extension HistoryEffectHandler {
    
    typealias Event = HistoryEvent
    typealias Effect = HistoryEffect
    typealias Dispatch = (Event) -> Void
}
