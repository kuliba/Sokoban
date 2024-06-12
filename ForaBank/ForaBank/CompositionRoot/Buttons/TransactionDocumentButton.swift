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
    
    let getValue: GetValue
    
    var body: some View {
        
        MagicButtonWithSheet(
            buttonLabel: buttonLabel,
            getValue: getValue,
            makeValueView: makePDFDocumentView
        )
    }
}

extension TransactionDocumentButton {
    
    typealias GetValueCompletion = (PDFDocument?) -> Void
    typealias GetValue = (@escaping GetValueCompletion) -> Void
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
