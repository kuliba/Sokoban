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
            switch openCard {
            case let .form(form):
                makeOpenCardProductView(form.model, dismiss: dismiss)
                    .navigationBarWithBack(
                        title: "Заказать карту",
                        dismiss: dismiss
                    )
                
            case let .landing(binder):
                makeOrderCardLandingView(binder: binder, dismiss: dismiss)
            }

        case let .creditCardMVP(creditCardMVP):
            makeCreditCardMVPView(binder: creditCardMVP, dismiss: dismiss)
          
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
