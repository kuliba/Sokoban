//
//  DocumentButtonView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 14.03.2025.
//

import SwiftUI
import UIPrimitives

struct DocumentButton: View {

    let state: DocumentButtonDomain.State
    
    var body: some View {
        
        switch state {
        case let .completed(document):
            WithSheetView {
                circleButton(image: .ic24File, title: "Документ", action: $0)
            } sheet: {
                PDFDocumentView(document: document)
                    .navigationBarWithClose(title: "", dismiss: $0)
            }
            
        case .failure, .pending:
            EmptyView()
            
        case .loading:
            circleButtonPlaceholder()
        }
    }
    
    func circleButton(
        image: Image,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        
        ButtonIconTextView(viewModel: .init(
            icon: .init(image: image, background: .circle),
            title: .init(text: title),
            orientation: .vertical,
            action: action
        ))
        .frame(width: 100, height: 92, alignment: .top)
    }
    
    func circleButtonPlaceholder() -> some View {
        
        PaymentCompleteButtonsPlaceholderView(config: .iVortex)
            ._shimmering()
            .frame(width: 100, height: 92, alignment: .top)
    }
}

extension DocumentButton {
    
    static let preview = DocumentButton(state: .pending)
}
