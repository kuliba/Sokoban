//
//  TopUpCardView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 01.03.2024.
//

import SwiftUI
import ProductProfile
import TopUpCardUI

struct TopUpCardView: View {
    
    let state: ProductProfileNavigation.State
    let event: (ProductProfileNavigation.Event) -> Void
    
    var body: some View {
        
        topUpCardButton()
    }
    
    private func topUpCardButton() -> some View {
        
        Button(
            "Пополнить",
            action: { self.event(.create(.topUpCard)) }
        )
        .buttonStyle(.bordered)
        .controlSize(.large)
        .alert(
            item: .init(
                get: { state.alert },
                // set is called by tapping on alert buttons, that are wired to some actions, no extra handling is needed (not like in case of modal or navigation)
                set: { _ in }
            ),
            content: { .init(with: $0, event: event) }
        )
        .sheet(
            item: .init(
                get: {
                    if case let .topUpCard(route) = state.modal {
                        return route
                    } else { return nil }
                },
                set: { if $0 == nil { event(.dismissModal) }}
            ),
            content: destinationView
        )
    }
    
    private func destinationView(
        route: ProductProfileNavigation.State.TopUpCardRoute
    ) -> some View {
        
        TopUpCardWrappedView(
            viewModel: route.viewModel,
            config: .preview)
        .padding(.top, 26)
        .padding(.bottom, 72)
        .presentationDetents([.height(400)])
    }
}

#Preview {
    TopUpCardView.init(
        state: .init(),
        event: { _ in })
}

