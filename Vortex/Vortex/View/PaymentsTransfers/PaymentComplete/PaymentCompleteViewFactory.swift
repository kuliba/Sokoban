//
//  PaymentCompleteViewFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.06.2024.
//

import UIPrimitives

struct PaymentCompleteViewFactory {
    
    let makeDetailButton: MakeDetailButton
    let makeDocumentButton: MakeDocumentButton
    let makeIconView: MakeIconView
    let makeTemplateButton: MakeTemplateButtonView
    let makeTemplateButtonWrapperView: MakeTemplateButtonWrapperView
}

extension PaymentCompleteViewFactory {
    
    typealias MakeDetailButton = (TransactionDetailButton.Details) -> TransactionDetailButton
    typealias MakeDocumentButton = (DocumentID, RequestFactory.PrintFormType) -> TransactionDocumentButton
    typealias MakeIconView = (String?) -> UIPrimitives.AsyncImage
    typealias MakeTemplateButtonView = () -> TemplateButtonStateWrapperView?
}
