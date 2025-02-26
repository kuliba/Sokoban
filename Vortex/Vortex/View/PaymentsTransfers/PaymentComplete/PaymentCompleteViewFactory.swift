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
    
    init(
        makeDetailButton: @escaping MakeDetailButton,
        makeDocumentButton: @escaping MakeDocumentButton,
        makeIconView: @escaping MakeIconView,
        makeTemplateButton: @escaping MakeTemplateButtonView,
        makeTemplateButtonWrapperView: @escaping MakeTemplateButtonWrapperView
    ) {
        self.makeDetailButton = makeDetailButton
        self.makeDocumentButton = makeDocumentButton
        self.makeIconView = makeIconView
        self.makeTemplateButton = makeTemplateButton
        self.makeTemplateButtonWrapperView = makeTemplateButtonWrapperView
    }
}

extension PaymentCompleteViewFactory {
    
    typealias MakeDetailButton = (TransactionDetailButton.Details) -> TransactionDetailButton
    typealias MakeDocumentButton = (DocumentID, RequestFactory.PrintFormType) -> TransactionDocumentButton
    typealias MakeIconView = (String?) -> UIPrimitives.AsyncImage
    typealias MakeTemplateButtonView = () -> TemplateButtonStateWrapperView?
}
