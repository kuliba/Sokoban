//
//  PDFDocumentButton.swift
//  Vortex
//
//  Created by Valentin Ozerov on 12.02.2025.
//

import ButtonWithSheet
import PDFKit
import SwiftUI
import CollateralLoanLandingGetShowcaseUI

struct PDFDocumentButton: View {
    
    let getDocument: GetDocument
    
    var body: some View {
        
        MagicButtonWithSheet(
            buttonLabel: buttonLabel,
            getValue: getDocument,
            makeValueView: makePDFDocumentView
        )
    }
}

extension PDFDocumentButton {
    
    typealias Payload = CollateralLandingApplicationGetConsentsPayload
    typealias GetDocumentCompletion = (PDFDocument?) -> Void
    typealias GetDocument = (@escaping GetDocumentCompletion) -> Void
    typealias GetPDFDocument = (Payload, @escaping GetDocumentCompletion) -> Void
}

// MARK: - Helpers

private extension PDFDocumentButton {
    
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

extension PDFDocumentButton {
    
    static let preview = Self(getDocument: { _ in })
}
