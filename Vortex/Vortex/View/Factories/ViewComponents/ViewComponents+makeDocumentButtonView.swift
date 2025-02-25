//
//  ViewComponents+makeDocumentButtonView.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.02.2025.
//

import SwiftUI
import UIPrimitives

extension ViewComponents {
    
    @inlinable
    @ViewBuilder
    func makeDocumentButtonView(
        state: DocumentButtonDomain.State
    ) -> some View {
        
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
}

struct MakeDocumentButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        HStack {
            
            makeDocumentButtonView(.completed(.sample))
            makeDocumentButtonView(.failure(NSError(domain: "Load PDF Failure", code: -1)))
            makeDocumentButtonView(.loading(nil))
            makeDocumentButtonView(.pending)
        }
    }
    private static func makeDocumentButtonView(
        _ state: DocumentButtonDomain.State
    ) -> some View {
        
        ViewComponents.preview.makeDocumentButtonView(state: state)
    }
}
