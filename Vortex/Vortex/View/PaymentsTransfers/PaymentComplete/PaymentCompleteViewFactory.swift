//
//  PaymentCompleteViewFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.06.2024.
//

import UIPrimitives
import CollateralLoanLandingGetShowcaseUI

struct PaymentCompleteViewFactory {
    
    let makeDetailButton: MakeDetailButton
    let makeDocumentButton: MakeDocumentButton
    let makeIconView: MakeIconView
    let makeTemplateButton: MakeTemplateButtonView
    let makeTemplateButtonWrapperView: MakeTemplateButtonWrapperView
    let makePDFDocumentButton: MakePDFDocumentButton?
    
    init(
        makeDetailButton: @escaping MakeDetailButton,
        makeDocumentButton: @escaping MakeDocumentButton,
        makeIconView: @escaping MakeIconView,
        makeTemplateButton: @escaping MakeTemplateButtonView,
        makeTemplateButtonWrapperView: @escaping MakeTemplateButtonWrapperView,
        makePDFDocumentButton: MakePDFDocumentButton? = nil
    ) {
        self.makeDetailButton = makeDetailButton
        self.makeDocumentButton = makeDocumentButton
        self.makeIconView = makeIconView
        self.makeTemplateButton = makeTemplateButton
        self.makeTemplateButtonWrapperView = makeTemplateButtonWrapperView
        self.makePDFDocumentButton = makePDFDocumentButton
    }
}

extension PaymentCompleteViewFactory {
    
    typealias MakeDetailButton = (TransactionDetailButton.Details) -> TransactionDetailButton
    typealias MakeDocumentButton = (DocumentID, RequestFactory.PrintFormType) -> TransactionDocumentButton
    typealias MakeIconView = (String?) -> UIPrimitives.AsyncImage
    typealias MakeTemplateButtonView = () -> TemplateButtonStateWrapperView?
    typealias MakePDFDocumentButton = (CollateralLandingApplicationGetConsentsPayload) -> PDFDocumentButton
}
