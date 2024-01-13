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
            
            NavigationStack {
                
                VStack(spacing: 32) {
                    
                    showLoaderButton()
                    showAlertButton()
                    openFastPaymentsSettingsButton()
                }
                .alert(
                    item: .init(
                        get: { viewModel.route.modal?.alert },
                        set: { if $0 == nil { viewModel.resetModal() }}
                    ),
                    content: Alert.init(with:)
                )
                .navigationDestination(
                    item: .init(
                        get: { viewModel.route.destination },
                        set: { if $0 == nil { viewModel.resetDestination() }}
                    ),
                    destination: destinationView
                )
            }
            
            viewModel.informer.map(informerView)
            
            loader()
        }
        .overlay(alignment: .bottom) {
            
            VStack {
                
                Text("destination: \(viewModel.route.destination == nil ? "nil" : "value")")
                Text("fpsDestination: \(viewModel.route.fpsDestination == nil ? "nil" : "value")")
                Text("modal: \(viewModel.route.modal == nil ? "nil" : "value")")
                Text("isLoading: \(viewModel.route.isLoading ? "true" : "false")")
                Text("informer: \(viewModel.informer == nil ? "nil" : "value")")
            }
            .foregroundStyle(.secondary)
            .font(.footnote)
        }
    }
    
    private func showLoaderButton() -> some View {
        
        Button("show loader", action: viewModel.showDemoLoader)
    }
    
    private func showAlertButton() -> some View {
        
        Button("show alert", action: viewModel.showDemoAlert)
    }
    
    private func openFastPaymentsSettingsButton() -> some View {
        
        Button(
            "Fast Payments Settings",
            action: viewModel.openFastPaymentsSettings
        )
    }
    
    private func informerView(
        informer: UserAccountViewModel.Informer
    ) -> some View {
        
        InformerView(text: informer.text)
    }
    
    @ViewBuilder
    private func loader() -> some View {
        
        ZStack {
            
            Color.black.opacity(0.4)
            
            ProgressView()
        }
        .ignoresSafeArea()
        .opacity(viewModel.route.isLoading ? 1 : 0)
    }
    
    private func destinationView(
        destination: UserAccountViewModel.Route.Destination
    ) -> some View {
        
        switch destination {
        case let .fastPaymentsSettings(fpsViewModel):
            FastPaymentsSettingsView(viewModel: fpsViewModel)
                .onAppear { fpsViewModel.event(.appear) }
                .alert(
                    item: .init(
                        get: { viewModel.route.modal?.fpsAlert },
                        set: { if $0 == nil { viewModel.resetModal() }}
                    ),
                    content: Alert.init(with:)
                )
                .navigationDestination(
                    item: .init(
                        get: { viewModel.route.fpsDestination },
                        set: { if $0 == nil { viewModel.resetFPSDestination() }}
                    ),
                    destination: fpsDestinationView
                )
        }
    }

    private func fpsDestinationView(
        fpsDestination: UserAccountViewModel.Route.FPSDestination
    ) -> some View {
        
        switch fpsDestination {
        case .confirmSetBankDefault:
            Text("TBD: OTP Confirmation")
        }
    }
}

struct UserAccountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountView(viewModel: .preview())
    }
}
