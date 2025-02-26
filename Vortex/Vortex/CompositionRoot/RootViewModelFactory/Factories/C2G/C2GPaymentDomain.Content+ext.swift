//
//  C2GPaymentDomain.Content+ext.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import CombineSchedulers
import Foundation
import C2GCore
import PaymentComponents

extension C2GPaymentDomain.Content {
    
    convenience init(
        payload: C2GPaymentDomain.ContentPayload,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        let initialState = C2GPaymentState(payload: payload)
        
        let productSelectReducer = ProductSelectReducer(
            getProducts: { payload.products }
        )
        let reducer = C2GPaymentDomain.ContentReducer(
            productSelectReduce: productSelectReducer.reduce
        )
        
        self.init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: { _,_ in },
            scheduler: scheduler
        )
    }
}

// MARK: - Helpers

private extension C2GPaymentState
where Context == C2GPaymentDomain.Context {
    
    init(
        payload: C2GPaymentDomain.ContentPayload
    ) {
        self.init(
            context: .init(
                dateN: payload.dateN,
                discount: payload.discount,
                discountExpiry: payload.discountExpiry,
                formattedAmount: payload.formattedAmount,
                legalAct: payload.legalAct,
                merchantName: payload.merchantName,
                payerINN: payload.payerINN,
                payerKPP: payload.payerKPP,
                paymentTerm: payload.paymentTerm,
                purpose: payload.purpose,
                term: .terms(url: payload.url),
                uin: payload.uin
            ),
            productSelect: .init(selected: payload.selectedProduct),
            termsCheck: payload.termsCheck,
            uin: payload.uin
        )
    }
}

private extension AttributedString {
    
    static func terms(url: URL?) -> Self {
        
        var attributedString = AttributedString.turnSBPOnMessage
        attributedString.foregroundColor = .textPlaceholder
        attributedString.font = .textBodyMR14200()
        
        if let url, let terms = attributedString.range(of: String.termURLPlace) {
            
            attributedString[terms].link = url
            attributedString[terms].underlineStyle = .single
            attributedString[terms].foregroundColor = .textSecondary
        }
        
        return attributedString
    }
}

private extension AttributedString {
    
    static let turnSBPOnMessage: Self = .init("Включить переводы через СБП,\n\(String.termURLPlace)")
}

private extension String {
    
    static let termURLPlace = "принять условия обслуживания"
}
