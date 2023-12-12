//
//  DecoratedProductSelectView.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SwiftUI

struct DecoratedProductSelectView: View {
    
    typealias Event = SberQRConfirmPaymentEvent.ProductSelectEvent
    
    let state: ProductSelect
    let event: (Event) -> Void
    let backgroundColor: Color
    
    var body: some View {
        
        ProductSelectView(state: state, event: event)
            .animation(.easeInOut, value: state)
            .padding(10)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
    }
}

// MARK: - Previews

struct DecoratedProductSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            decoratedProductSelectView(state: .compact(.accountPreview))
            decoratedProductSelectView(state: .compact(.cardPreview))
            
            decoratedProductSelectView(state: .expanded(
                .accountPreview,
                [.accountPreview, .cardPreview]
            ))
            decoratedProductSelectView(state: .expanded(
                .cardPreview,
                [.accountPreview, .cardPreview]
            ))
        }
        .padding(.horizontal)
    }
     
    private static func decoratedProductSelectView(
        state: ProductSelect
    ) -> some View {
        
        DecoratedProductSelectView(
            state: state,
            event: { _ in },
            backgroundColor: .pink.opacity(0.1)
        )
    }
}
