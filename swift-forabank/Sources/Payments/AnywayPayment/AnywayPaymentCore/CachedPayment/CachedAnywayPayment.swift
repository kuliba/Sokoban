//
//  CachedAnywayPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 06.06.2024.
//

import AnywayPaymentDomain
import ForaTools
import Foundation

public struct CachedAnywayPayment<ElementModel> {
    
    private let cachedModels: CachedModels
    public let footer: UIFooter
    public let isFinalStep: Bool
    
    private init(
        cachedModels: CachedModels,
        footer: UIFooter,
        isFinalStep: Bool
    ) {
        self.cachedModels = cachedModels
        self.footer = footer
        self.isFinalStep = isFinalStep
    }
    
    public init(
        _ payment: AnywayPayment,
        using map: @escaping Map
    ) {
        self.init(
            cachedModels: .init(pairs: payment.elements.map { ($0.id, map($0)) }),
            footer: payment.uiFooter,
            isFinalStep: payment.isFinalStep
        )
    }
    
    public typealias CachedModels = CachedModelsState<AnywayElement.ID, ElementModel>
    public typealias Map = (AnywayElement) -> ElementModel
}

public enum UIFooter: Equatable {
    
    case amount(Amount)
    case `continue`
    
    public struct Amount: Equatable {
        
        public let amount: Decimal
        public let currency: String
        
        public init(
            amount: Decimal,
            currency: String
        ) {
            self.amount = amount
            self.currency = currency
        }
    }
}

extension CachedAnywayPayment: Equatable where ElementModel: Equatable {}

extension CachedAnywayPayment {
    
    public var models: [IdentifiedModel] {
        
        cachedModels.keyModelPairs.map(IdentifiedModel.init)
    }
    
    public struct IdentifiedModel: Identifiable {
        
        public let id: AnywayElement.ID
        public let model: ElementModel
        
        public init(
            id: AnywayElement.ID,
            model: ElementModel
        ) {
            self.id = id
            self.model = model
        }
    }
}

extension CachedAnywayPayment.IdentifiedModel: Equatable where ElementModel: Equatable {}

extension CachedAnywayPayment {
    
    public func updating(
        with payment: AnywayPayment,
        using map: @escaping Map
    ) -> Self {
        
        let updatedCachedModels = cachedModels.updating(
            with: payment.elements,
            using: map
        )
        return .init(
            cachedModels: updatedCachedModels,
            footer: payment.uiFooter,
            isFinalStep: payment.isFinalStep
        )
    }
}

private extension AnywayPayment {
    
    var uiFooter: UIFooter {
        
        switch footer {
        case .amount:
            return uiAmount.map(UIFooter.amount) ?? .continue
            
        case .continue:
            return .continue
        }
    }
    
    private var uiAmount: UIFooter.Amount? {
        
        guard let amount, let currency else { return nil }
        
        return .init(amount: amount, currency: currency)
    }
    
    var currency: String? {
        
        guard case let .widget(.product(product)) = elements[id: .widgetID(.product)]
        else { return nil }
        
        return product.currency
    }
}
