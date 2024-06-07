//
//  CachedPaymentContext.swift
//
//
//  Created by Igor Malyarov on 06.06.2024.
//

import AnywayPaymentDomain

public struct CachedPaymentContext<ElementModel> {
    
    public let payment: CachedPayment
    public let staged: AnywayPaymentStaged
    public let outline: AnywayPaymentOutline
    public var shouldRestart: Bool
    
    public init(
        payment: CachedPayment,
        staged: AnywayPaymentStaged,
        outline: AnywayPaymentOutline,
        shouldRestart: Bool
    ) {
        self.payment = payment
        self.staged = staged
        self.outline = outline
        self.shouldRestart = shouldRestart
    }
    
    public typealias CachedPayment = CachedAnywayPayment<ElementModel>
}

public extension CachedPaymentContext {
    
    func updating(
        with context: AnywayPaymentContext,
        using map: @escaping Map
    ) -> Self {
        
        return .init(
            payment: payment.updating(with: context.payment, using: map),
            staged: context.staged,
            outline: context.outline,
            shouldRestart: context.shouldRestart
        )
    }
    
    typealias Map = (AnywayPayment.Element) -> (ElementModel)
}
