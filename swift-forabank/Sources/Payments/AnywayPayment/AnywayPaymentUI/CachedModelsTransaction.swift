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
            models: transaction.updatingModels(models, using: map),
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
    
    typealias Map = (AnywayElement) -> Model
    typealias MakeFooter = (Transaction) -> Footer
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
        
        // remove models for keys that are no longer in elements
        let keepers = models.filter { Set(context.payment.elements.map(\.id)).contains($0.key) }
        
        let existingIDs = Set(keepers.keys)
        let newModels = context.payment.elements
            .filter { !existingIDs.contains($0.id) }
            .map { ($0.id, map($0)) }
        
        let models = keepers.merging(newModels) { _, last in last }
        
        return models
    }
    
    typealias Models<Model> = [AnywayElement.ID: Model]
}
