//
//  ContentView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        openFastPaymentsSettingsButton()
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
    
    private func destinationView(
        destination: ViewModel.Route.Destination
    ) -> some View {
        
        switch destination {
        case let .fastPaymentsSettings(fpsViewModel):
            FastPaymentsSettingsView(viewModel: fpsViewModel)
                .onAppear { fpsViewModel.event(.appear) }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView(viewModel: .preview())
    }
}
