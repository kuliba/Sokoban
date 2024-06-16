//
//  CachedModelsTransaction.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentDomain

struct CachedModelsTransaction<Model, DocumentStatus, Response> {
    
    let models: [ID: Model]
    let transaction: Transaction
    
    private init(
        models: [ID : Model],
        transaction: Transaction
    ) {
        self.models = models
        self.transaction = transaction
    }
    
    typealias ID = AnywayElement.ID
    typealias Transaction = AnywayTransactionState<DocumentStatus, Response>
}

extension CachedModelsTransaction {
    
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

extension CachedModelsTransaction: Equatable where Model: Equatable, DocumentStatus: Equatable, Response: Equatable {}
