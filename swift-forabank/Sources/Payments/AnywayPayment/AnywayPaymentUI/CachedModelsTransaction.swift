//
//  CachedModelsTransaction.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain

public struct CachedModelsTransaction<Model, DocumentStatus, Response> {
    
    public let models: [ID: Model]
    public let transaction: Transaction
    
    internal init(
        models: [ID : Model],
        transaction: Transaction
    ) {
        self.models = models
        self.transaction = transaction
    }
    
    public typealias ID = AnywayElement.ID
    public typealias Transaction = AnywayTransactionState<DocumentStatus, Response>
}

public extension CachedModelsTransaction {
    
    init(
        with transaction: Transaction,
        using map: @escaping Map
    ) {
        let pairs = transaction.context.payment.elements.map { ($0.id, map($0)) }
        let models = Dictionary(uniqueKeysWithValues: pairs)
        
        self.init(models: models, transaction: transaction)
    }
    
    func updating(
        with transaction: Transaction,
        using map: @escaping Map
    ) -> Self {
        
        let existingIDs = Set(models.keys)
        let newModels = transaction.context.payment.elements
            .filter { !existingIDs.contains($0.id) }
            .map { ($0.id, map($0)) }
        let models = models.merging(newModels) { _, last in last }
        
        return .init(models: models, transaction: transaction)
    }
    
    typealias Map = (AnywayElement) -> Model
}

public extension CachedModelsTransaction {
    
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

extension CachedModelsTransaction: Equatable where Model: Equatable, DocumentStatus: Equatable, Response: Equatable {}
