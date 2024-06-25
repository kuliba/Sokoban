//
//  CachedPayment.swift
//  CachedModelsStatePreview
//
//  Created by Igor Malyarov on 05.06.2024.
//

import ForaTools

struct CachedPayment {
    
    private let cachedModels: CachedModels
    
    private init(cachedModels: CachedModels) {
        
        self.cachedModels = cachedModels
    }
    
    init(pairs: [(Element.ID, ElementModel)]) {
        
        self.cachedModels = .init(pairs: pairs)
    }
    
    typealias CachedModels = CachedModelsState<Element.ID, ElementModel>
    typealias Element = Payment.Element
    
    enum ElementModel {
        
        case field(InputViewModel)
        case param(InputViewModel)
    }
}

extension CachedPayment {
    
    var models: [IdentifiedModels] {
        
        cachedModels.keyModelPairs.map(IdentifiedModels.init)
    }
    
    struct IdentifiedModels: Identifiable {
        
        let id: Element.ID
        let model: ElementModel
    }
    
    func updating(
        with elements: [Element],
        using map: @escaping (Element) -> (ElementModel)
    ) -> Self {
        
        let updatedCachedModels = cachedModels.updating(with: elements, using: map)
        return .init(cachedModels: updatedCachedModels)
    }
}

enum CachedPaymentEvent: Equatable {
    
    case update([Payment.Element])
}

enum CachedPaymentEffect: Equatable {}

final class CachedPaymentReducer {
    
    private let map: Map
    
    init(
        map: @escaping Map
    ) {
        self.map = map
    }
    
    typealias Map = (Element) -> ElementModel
    typealias Element = State.Element
    typealias ElementModel = State.ElementModel
}

extension CachedPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .update(fields):
            state = state.updating(with: fields, using: map)
        }
        
        return (state, nil)
    }
}

extension CachedPaymentReducer {
    
    typealias State = CachedPayment
    typealias Event = CachedPaymentEvent
    typealias Effect = CachedPaymentEffect
}
