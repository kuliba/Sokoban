//
//  UserAccountView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import SwiftUI

struct UserAccountView: View {
    
    @ObservedObject var viewModel: UserAccountViewModel
    
    var body: some View {
        
        ZStack {
            
            openFastPaymentsSettingsButton()
            
            loader()
        }
            .navigationDestination(
                item: .init(
                    get: { viewModel.route.destination },
                    set: { if $0 == nil { viewModel.resetDestination() }}
                ),
                destination: destinationView
            )
            .alert(
                item: .init(
                    get: { viewModel.route.modal?.alert },
                    set: { if $0 == nil { viewModel.resetModal() }}
                ),
                content: Alert.init(with:)
            )
    }
    
    private func openFastPaymentsSettingsButton() -> some View {
        
        Button(
            "Fast Payments Settings",
            action: viewModel.openFastPaymentsSettings
        )
    }
    
    @ViewBuilder
    private func loader() -> some View {
        
        ZStack {
            
            Color.black.opacity(0.4)
            
            ProgressView()
        }
        .ignoresSafeArea()
        .opacity(viewModel.route.loader ? 1 : 0)
    }
    
    private func destinationView(
        destination: UserAccountViewModel.Route.Destination
    ) -> some View {
        
        switch destination {
        case let .fastPaymentsSettings(fpsViewModel):
            FastPaymentsSettingsView(viewModel: fpsViewModel)
                .onAppear { fpsViewModel.event(.appear) }
        }
    }
}

struct UserAccountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountView(viewModel: .preview())
    }
}
