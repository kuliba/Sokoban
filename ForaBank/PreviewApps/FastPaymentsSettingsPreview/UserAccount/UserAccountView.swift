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
            
            InformerView(viewModel: viewModel.informer)
            
            loader()
        }
    }
    
    private func openFastPaymentsSettingsButton() -> some View {
        
        Button(
            "Fast Payments Settings",
            action: viewModel.openFastPaymentsSettings
        )
        .buttonStyle(.borderedProminent)
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
            ConfirmOTPStubView(onCommit: viewModel.handleOTPResult)
        }
    }
}

struct UserAccountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountView(viewModel: .preview())
    }
}

struct ConfirmOTPStubView: View {
    
    let onCommit: (ConfirmWithOTPResult) -> Void
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            Text("OTP Confirmation Stub")
                .font(.title3.bold())
            
            VStack(spacing: 32) {
                
                Button("Confirm OK") { onCommit(.success) }
                Button("Incorrect Code") { onCommit(.incorrectCode) }
                Button("Server Error") { onCommit(.serverError("Возникла техническая ошибка (код 4044). Свяжитесь с поддержкой банка для уточнения")) }
                Button("Connectivity Error") { onCommit(.connectivityError) }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

enum ConfirmWithOTPResult {
    
    case success
    case incorrectCode
    case serverError(String)
    case connectivityError
}
