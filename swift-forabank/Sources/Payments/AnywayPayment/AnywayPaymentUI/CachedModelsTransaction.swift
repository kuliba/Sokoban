//
//  CachedModelsTransaction.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain

public struct CachedModelsTransaction<AmountViewModel, Model, DocumentStatus, Response> {
    
    public let models: Models
    public let footer: AmountFooter
    public let transaction: Transaction
    
    internal init(
        models: Models,
        footer: AmountFooter = .continueButton,
        transaction: Transaction
    ) {
        self.models = models
        self.footer = footer
        self.transaction = transaction
    }
    
    public typealias ID = AnywayElement.ID
    public typealias Models = [ID: Model]
    public typealias AmountFooter = Footer<AmountViewModel>
    public typealias Transaction = AnywayTransactionState<DocumentStatus, Response>
}

public extension CachedModelsTransaction {
    
    init(
        with transaction: Transaction,
        using map: @escaping Map,
        makeAmountViewModel: @escaping MakeAmountViewModel
    ) {
        self.init(
            models: transaction.makeModels(using: map),
            footer: transaction.makeFooter(
                using: makeAmountViewModel
            ),
            transaction: transaction
        )
    }
    
    func updating(
        with transaction: Transaction,
        using map: @escaping Map,
        makeAmountViewModel: @escaping MakeAmountViewModel
    ) -> Self {
        
        return .init(
            models: transaction.updatingModels(models, using: map),
            footer: transaction.updatingFooter(footer, using: makeAmountViewModel),
            transaction: transaction
        )
    }
    
    typealias Map = (AnywayElement) -> Model
    typealias MakeAmountViewModel = (Transaction) -> AmountViewModel
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
    
    func makeFooter<AmountViewModel>(
        using makeAmountViewModel: (Self) -> AmountViewModel
    ) -> Footer<AmountViewModel> {
        
        let digest = context.makeDigest()
        
        guard digest.amount != nil,
              digest.core?.currency != nil
        else { return .continueButton }
        
        return .amount(makeAmountViewModel(self))
    }
    
    func updatingFooter<AmountViewModel>(
        _ footer: Footer<AmountViewModel>,
        using makeAmountViewModel: (Self) -> AmountViewModel
    ) -> Footer<AmountViewModel> {
        
        let newFooter = makeFooter(using: makeAmountViewModel)
        
        switch (footer, newFooter) {
        case (.continueButton, _):
            return newFooter
            
        case (_, .continueButton):
            return .continueButton
            
        case let (.amount(amountViewModel), .amount):
            return .amount(amountViewModel)
        }
    }
}
