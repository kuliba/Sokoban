//
//  CachedPayment.swift
//  CachedModelsStatePreview
//
//  Created by Igor Malyarov on 05.06.2024.
//

import ForaTools

struct CachedPayment {
    
    let state: State
    
    typealias State = CachedModelsState<Payment.Field.ID, FieldModel>
    typealias FieldModel = InputViewModel
}

extension CachedPayment {
    
    var fields: [FieldModel] { state.models }
}
