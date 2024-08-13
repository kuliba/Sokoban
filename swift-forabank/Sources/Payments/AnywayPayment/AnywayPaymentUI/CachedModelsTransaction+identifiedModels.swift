//
//  CachedModelsTransaction+identifiedModels.swift
//  
//
//  Created by Igor Malyarov on 12.08.2024.
//

import AnywayPaymentDomain
import AnywayPaymentCore

public extension CachedModelsTransaction {
    
    /// Use in SwiftUI view.
    var identifiedModels: [IdentifiedModel] {
        
        transaction.context.payment.elements.compactMap { element in
            
            models[element.id].map { .init(id: element.id, model: $0)}
        }
    }
    
    struct IdentifiedModel: Identifiable {
        
        public let id: AnywayElement.ID
        public let model: Model
    }
}
