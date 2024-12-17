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
        let state: FilterHistoryState
    }
    
    typealias MakeFilterModelCompletion = (FilterViewModel) -> Void
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
        case let .filter(productId: productId, state: state):
            
            microServices.makeFilterModel(.init(
                productId: productId,
                state: state
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
