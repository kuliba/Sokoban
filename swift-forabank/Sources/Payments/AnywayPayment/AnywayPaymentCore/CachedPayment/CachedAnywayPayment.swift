//
//  CachedAnywayPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 06.06.2024.
//

import AnywayPaymentDomain
import ForaTools

public struct CachedAnywayPayment<ElementModel> {
    
    private let cachedModels: CachedModels
    public let infoMessage: String?
    public let isFinalStep: Bool
    public let isFraudSuspected: Bool
    public let puref: Puref
    
    private init(
        cachedModels: CachedModels,
        infoMessage: String?,
        isFinalStep: Bool,
        isFraudSuspected: Bool,
        puref: Puref
    ) {
        self.cachedModels = cachedModels
        self.infoMessage = infoMessage
        self.isFinalStep = isFinalStep
        self.isFraudSuspected = isFraudSuspected
        self.puref = puref
    }
    
    public init(
        _ payment: AnywayPayment,
        using map: @escaping Map
    ) {
        self.init(
            cachedModels: .init(pairs: payment.elements.map { ($0.id, map($0)) }),
            infoMessage: payment.infoMessage,
            isFinalStep: payment.isFinalStep,
            isFraudSuspected: payment.isFraudSuspected,
            puref: payment.puref
        )
    }
}

public extension CachedAnywayPayment {
    
    typealias CachedModels = CachedModelsState<Element.ID, ElementModel>
    typealias Element = AnywayElement
    
    typealias Puref = AnywayPayment.Puref
    
    typealias Map = (Element) -> ElementModel
}

extension CachedAnywayPayment: Equatable where ElementModel: Equatable {}

extension CachedAnywayPayment {
    
    public var models: [IdentifiedModel] {
        
        cachedModels.keyModelPairs.map(IdentifiedModel.init)
    }
    
    public struct IdentifiedModel: Identifiable {
        
        public let id: Element.ID
        public let model: ElementModel
        
        public init(
            id: Element.ID,
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
            infoMessage: payment.infoMessage,
            isFinalStep: payment.isFinalStep,
            isFraudSuspected: payment.isFraudSuspected,
            puref: payment.puref
        )
    }
}
