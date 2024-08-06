//
//  CachedModelsTransaction.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import Foundation
import PaymentComponents

public struct CachedModelsTransaction<Footer, Model, DocumentStatus, Response> {
    
    public let models: Models
    public let footer: Footer
    public let transaction: Transaction
    internal let isAwaitingConfirmation: Bool
    
    public typealias ID = AnywayElement.ID
    public typealias Models = [ID: Model]
    public typealias Transaction = AnywayTransactionState<DocumentStatus, Response>
}

public extension CachedModelsTransaction 
where Footer: FooterInterface & Receiver<Decimal>,
      DocumentStatus: Equatable,
      Response: Equatable {
    
    init(
        with transaction: Transaction,
        using map: @escaping Map,
        makeFooter: @escaping MakeFooter
    ) {
        self.init(
            models: transaction.makeModels(using: map),
            footer: makeFooter(transaction),
            transaction: transaction,
            isAwaitingConfirmation: transaction.status == .awaitingPaymentRestartConfirmation
        )
    }
    
    func updating(
        with transaction: Transaction,
        using map: @escaping Map
    ) -> Self {
        
        updateFooter(with: transaction)
        
        return .init(
            models: transaction.updatingModels(
                models,
                using: map,
                shouldRecreateModels: shouldRecreateModels(transaction)
            ),
            footer: footer,
            transaction: transaction,
            isAwaitingConfirmation: transaction.status == .awaitingPaymentRestartConfirmation
        )
    }
    
    func updateFooter(
        with transaction: Transaction
    ) {
        transaction.context.payment.amount.map(footer.receive)
        
        let isEnabled: Bool = {
            switch transaction.status {
            case .inflight: return false
            default:        return transaction.isValid
            }
        }()
        let style: AmountComponent.FooterState.Style = {
            
            switch transaction.context.payment.footer {
            case .amount:   return .amount
            case .continue: return .button
            }
        }()
        let projection = FooterTransactionProjection(
            isEnabled: isEnabled,
            style: style
        )
        
        footer.project(projection)
    }
    
    // should reset model if status was awaitingPaymentRestartConfirmation, i.e. isAwaitingConfirmation == true, and now is not awaitingPaymentRestartConfirmation
    private func shouldRecreateModels(
        _ transaction: Transaction
    ) -> Bool {
        
        switch transaction.status {
        case .awaitingPaymentRestartConfirmation:
            return false
            
        default:
            return isAwaitingConfirmation
        }
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
        using map: @escaping (AnywayElement) -> Model,
        shouldRecreateModels: Bool
    ) -> Models<Model> {
        
        guard !shouldRecreateModels else { return makeModels(using: map) }
        
        let existingIDs = Set(models.keys)
        let newModels = context.payment.elements
            .filter { !existingIDs.contains($0.id) }
            .map { ($0.id, map($0)) }
        let models = models.merging(newModels) { _, last in last }
        
        return models
    }
    
    typealias Models<Model> = [AnywayElement.ID: Model]
}
