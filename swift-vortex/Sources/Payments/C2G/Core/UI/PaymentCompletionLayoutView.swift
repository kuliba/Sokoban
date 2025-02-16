//
//  PaymentCompletionLayoutView.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import SwiftUI

struct PaymentCompletionLayoutView<Buttons, Footer, StatusView>: View
where Buttons: View,
      Footer: View,
      StatusView: View {
    
    let buttons: () -> Buttons
    let footer: () -> Footer
    let statusView: () -> StatusView
    
    var body: some View {
        
        // TODO: - extract config
        
        VStack {
            
            statusView() // PaymentCompletionStatusView
            
            Spacer()
            
            buttons()
                .padding(.bottom, 56)
        }
        .safeAreaInset(edge: .bottom, content: footer)
    }
}

#Preview {
    
    PaymentCompletionLayoutView(
        buttons: { Color.green.frame(height: 92) },
        footer: { Color.orange.frame(height: 112)},
        statusView: { Color.gray.frame(height: 280) }
    )
}
