//
//  PDFDocumentWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import PDFKit
import SwiftUI

struct PDFDocumentWrapperView: View {
    
    @State private var isShowingSheet = false
    
    let pdfDocument: PDFDocument
    let dismissAction: () -> Void
    
    var body: some View {
        
        VStack {
            
            PDFDocumentView(document: pdfDocument)
            
            ButtonSimpleView(viewModel: .saveAndShare {
                
                isShowingSheet = true
            })
            .frame(height: 48)
            .padding()
        }
        .sheet(isPresented: $isShowingSheet) {
            
            ActivityView(
                viewModel: .init(
                    activityItems: [pdfDocument.dataRepresentation() as Any]
                )
            )
        }
    }
}

private extension ButtonSimpleView.ViewModel {
    
    static func saveAndShare(
        action: @escaping () -> Void
    ) ->  ButtonSimpleView.ViewModel {
        
        .init(
            title: "Сохранить или отправить",
            style: .red,
            action: action
        )
    }
}
