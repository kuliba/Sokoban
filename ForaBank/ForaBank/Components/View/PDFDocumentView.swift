//
//  PDFDocumentView.swift
//  ForaBank
//
//  Created by Max Gribov on 04.07.2022.
//

import SwiftUI
import PDFKit

struct PDFDocumentView: UIViewRepresentable {

    let document: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.pageBreakMargins = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        pdfView.autoScales = true
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct PDFDocumentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PDFDocumentView(document: .sample)
    }
}

//MARK: - Preview Content

extension PDFDocument {
    
    static let sample: PDFDocument = {
        
        let bundle = Bundle(for: MainViewModel.self)
        let url = bundle.url(forResource: "sample_pdf", withExtension: "pdf")!
        
        return PDFDocument(url: url)!
        
    }()
}
