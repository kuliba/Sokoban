//
//  ControlButtonView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import SwiftUI
import CardGuardianUI
import ProductProfile

struct ControlButtonView: View {
    
    let state: ProductProfileNavigation.State
    let event: (ProductProfileNavigation.Event) -> Void
    
    var body: some View {
        
        openCardGuardianButton()
    }
    
    private func openCardGuardianButton() -> some View {
        
        Button(
            "Управление",
            action: { self.event(.create(.cardGuardian)) }
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
                    if case let .cardGuardian(route) = state.modal {
                        return route
                    } else { return nil }
                },
                set: { if $0 == nil { event(.dismissModal) }}
            ),
            content: destinationView
        )
    }
    
    private func destinationView(
        route: ProductProfileNavigation.State.CardGuardianRoute
    ) -> some View {
        
        CardGuardianUI.ThreeButtonsWrappedView(
            viewModel: route.viewModel,
            config: .preview)
        .padding(.top, 26)
        .padding(.bottom, 72)
        .presentationDetents([.height(300)])
    }
}

#Preview {
    ControlButtonView.init(
        state: .init(),
        event: { _ in })
}

