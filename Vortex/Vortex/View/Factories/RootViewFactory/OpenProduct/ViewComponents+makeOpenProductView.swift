//
//  ViewComponents+makeOpenProductView.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

import SwiftUI

extension ViewComponents {
    
    @ViewBuilder
    func makeOpenProductView(
        for openProduct: OpenProduct,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        switch openProduct {
        case let .card(openCard):
            makeOpenCardProductView(openCard.model, dismiss: dismiss)
                .navigationBarWithBack(
                    title: "Заказать карту",
                    dismiss: dismiss
                )
            
        case let .creditCardMVP:
            Text("TBD: creditCardMVP")
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationBarWithBack(
                    title: "Кредитная карта",
                    subtitle: "Всё включено",
                    subtitleForegroundColor: .textPlaceholder,
                    dismiss: dismiss
                )
          
        case let .savingsAccount(nodes):

            makeSavingsAccountBinderView(
                binder: nodes.savingsAccountNode.model,
                openAccountBinder: nodes.openSavingsAccountNode.model,
                dismiss: dismiss
            )
                .navigationBarHidden(true)

        case .unknown:
            Text("Unknown product")
                .foregroundStyle(.red)
        }
    }
}
