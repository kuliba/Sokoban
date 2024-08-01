//
//  PaymentCompleteViewFactory.swift
//  ForaBank
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
    typealias MakeDocumentButton = (DocumentID) -> TransactionDocumentButton
    typealias MakeTemplateButtonView = () -> TemplateButtonStateWrapperView?
}
