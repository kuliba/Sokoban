//
//  TransactionDocumentButton.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import ButtonWithSheet
import PDFKit
import SwiftUI

struct TransactionDocumentButton: View {
    
    let getDocument: GetDocument
    
    var body: some View {
        
        MagicButtonWithSheet(
            buttonLabel: buttonLabel,
            getValue: getDocument,
            makeValueView: makePDFDocumentView
        )
    }
}

extension TransactionDocumentButton {
    
    typealias GetDocumentCompletion = (PDFDocument?) -> Void
    typealias GetDocument = (@escaping GetDocumentCompletion) -> Void
}

// MARK: - Helpers

private extension TransactionDocumentButton {
    
    func buttonLabel() -> some View {
        
        PaymentsSuccessOptionButtonsView.ButtonView.ButtonLabel(with: .document)
    }
    
    func makePDFDocumentView(
        pdfDocument: PDFDocument,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        PDFDocumentWrapperView(
            pdfDocument: pdfDocument,
            dismissAction: dismiss
        )
    }
}
