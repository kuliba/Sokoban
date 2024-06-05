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
    
    var fields: [FieldModel] { cachedModels.models }
    
    func updating(
        with fields: [Field],
        using map: @escaping (Field) -> (FieldModel)
    ) -> Self {
        
        let updatedCachedModels = cachedModels.updating(with: fields, using: map)
        return .init(cachedModels: updatedCachedModels)
    }
}
