//
//  PaymentCompleteViewFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.06.2024.
//

struct PaymentCompleteViewFactory {
    
    let makeDetailButton: MakeDetailButton
    let makeDocumentButton: MakeDocumentButton
    let makeTemplateButton: MakeTemplateButtonView
}

extension PaymentCompleteViewFactory {
    
    typealias MakeDetailButton = (TransactionDetailButton.Details) -> TransactionDetailButton
    typealias MakeDocumentButton = (DocumentID, RequestFactory.PrintFormType) -> TransactionDocumentButton
    typealias MakeTemplateButtonView = () -> TemplateButtonStateWrapperView?
}
