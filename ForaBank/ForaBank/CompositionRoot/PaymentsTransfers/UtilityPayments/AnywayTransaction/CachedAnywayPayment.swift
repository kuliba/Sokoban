//
//  CachedAnywayPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 06.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import ForaTools

struct CachedAnywayPayment<ElementModel> {
    
    private let cachedModels: CachedModels
    let infoMessage: String?
    let isFinalStep: Bool
    let isFraudSuspected: Bool
    let puref: Puref
    
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
    
    init(
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
    
    typealias CachedModels = CachedModelsState<Element.ID, ElementModel>
    typealias Element = AnywayPayment.Element
    
    typealias Puref = AnywayPayment.Puref
    typealias AnywayPayment = AnywayPaymentDomain.AnywayPayment
    
    typealias Map = (Element) -> (ElementModel)
}

extension CachedAnywayPayment {
    
    var models: [IdentifiedModel] {
        
        cachedModels.keyModelPairs.map(IdentifiedModel.init)
    }
    
    struct IdentifiedModel: Identifiable {
        
        let id: Element.ID
        let model: ElementModel
    }
}

extension CachedAnywayPayment {
    
    func updating(
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
