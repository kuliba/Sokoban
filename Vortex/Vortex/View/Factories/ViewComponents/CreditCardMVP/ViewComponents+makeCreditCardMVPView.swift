//
//  ViewComponents+makeCreditCardMVPView.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeCreditCardMVPView(
        continue: @escaping () -> Void, // TOCO: call content on `continue`
        dismiss: @escaping () -> Void
    ) -> some View {
        
        Text("TBD: creditCardMVP")
            .frame(maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .bottom) {
                
                heroButton(action: `continue`)
                    .padding(.bottom, 8)
            }
            .padding([.horizontal, .top])
            .conditionalBottomPadding(12)
            .navigationBarWithBack(
                title: "Кредитная карта",
                subtitle: "Всё включено",
                subtitleForegroundColor: .textPlaceholder,
                dismiss: dismiss
            )
    }
}
