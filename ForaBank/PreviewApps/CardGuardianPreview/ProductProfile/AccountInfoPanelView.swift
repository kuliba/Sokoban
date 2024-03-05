//
//  AccountInfoPanelView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import SwiftUI
import ProductProfile
import AccountInfoPanel

struct AccountInfoPanelView: View {
    
    let state: ProductProfileNavigation.State
    let event: (ProductProfileNavigation.Event) -> Void
    
    var body: some View {
        
        accountInfoButton()
    }
    
    private func accountInfoButton() -> some View {
        
        Button(
            "Реквизиты\nи выписки",
            action: { self.event(.create(.accountInfo)) }
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
                    if case let .accountInfo(route) = state.modal {
                        return route
                    } else { return nil }
                },
                set: { if $0 == nil { event(.dismissDestination) }}
            ),
            content: destinationView
        )
    }
    
    private func destinationView(
        route: ProductProfileNavigation.State.AccountInfoRoute
    ) -> some View {
        
        AccountInfoPanelWrappedView(
            viewModel: route.viewModel,
            config: .preview)
        .padding(.top, 26)
        .padding(.bottom, 72)
        .presentationDetents([.height(300)])
    }
}

#Preview {
    AccountInfoPanelView.init(
        state: .init(),
        event: { _ in })
}

