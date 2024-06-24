//
//  CachedModelsTransaction.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain

public struct CachedModelsTransaction<Footer, Model, DocumentStatus, Response> {
    
    public let models: Models
    public let footer: Footer
    public let transaction: Transaction
    
    internal init(
        models: Models,
        footer: Footer,
        transaction: Transaction
    ) {
        self.models = models
        self.footer = footer
        self.transaction = transaction
    }
    
    public typealias ID = AnywayElement.ID
    public typealias Models = [ID: Model]
    public typealias Transaction = AnywayTransactionState<DocumentStatus, Response>
}

public extension CachedModelsTransaction {
    
    init(
        with transaction: Transaction,
        using map: @escaping Map,
        makeFooter: @escaping MakeFooter
    ) {
        self.init(
            models: transaction.makeModels(using: map),
            footer: makeFooter(transaction),
            transaction: transaction
        )
    }
    
    func updating(
        with transaction: Transaction,
        using map: @escaping Map
    ) -> Self {
        
        return .init(
            models: transaction.updatingModels(models, using: map),
            footer: footer,
            transaction: transaction
        )
    }
    
    typealias Map = (AnywayElement) -> Model
    typealias MakeFooter = (Transaction) -> Footer
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

extension Transaction where Context == AnywayPaymentContext {
    
    func makeModels<Model>(
        using map: @escaping (AnywayElement) -> Model
    ) -> Models<Model> {
        
        let pairs = context.payment.elements.map { ($0.id, map($0)) }
        let models = Dictionary(uniqueKeysWithValues: pairs)
        
        return models
    }
    
    func updatingModels<Model>(
        _ models: Models<Model>,
        using map: @escaping (AnywayElement) -> Model
    ) -> Models<Model> {
        
        let existingIDs = Set(models.keys)
        let newModels = context.payment.elements
            .filter { !existingIDs.contains($0.id) }
            .map { ($0.id, map($0)) }
        let models = models.merging(newModels) { _, last in last }
        
        return models
    }
    
    typealias Models<Model> = [AnywayElement.ID: Model]
}
