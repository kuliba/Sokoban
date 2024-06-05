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
    
    init(pairs: [(Field.ID, FieldModel)]) {
        
        self.cachedModels = .init(pairs: pairs)
    }
    
    typealias CachedModels = CachedModelsState<Field.ID, FieldModel>
    typealias Field = Payment.Field
    typealias FieldModel = InputViewModel
}

extension CachedPayment {
    
    var fields: [IdentifiedField] {
        
        cachedModels.keyModelPairs.map(IdentifiedField.init)
    }
    
    struct IdentifiedField: Identifiable {
        
        let id: Field.ID
        let model: FieldModel
    }
    
    func updating(
        with fields: [Field],
        using map: @escaping (Field) -> (FieldModel)
    ) -> Self {
        
        let updatedCachedModels = cachedModels.updating(with: fields, using: map)
        return .init(cachedModels: updatedCachedModels)
    }
}

enum CachedPaymentEvent: Equatable {
    
    case update([Field])
    
    typealias Field = Payment.Field
}

enum CachedPaymentEffect: Equatable {}

final class CachedPaymentReducer {
    
    private let map: Map
    
    init(map: @escaping Map) {
        self.map = map
    }
    
    typealias Map = (Field) -> FieldModel
    typealias Field = Payment.Field
    typealias FieldModel = InputViewModel
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
