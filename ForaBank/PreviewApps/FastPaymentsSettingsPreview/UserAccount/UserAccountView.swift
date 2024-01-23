//
//  UserAccountView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct UserAccountView: View {
    
    @ObservedObject var viewModel: UserAccountViewModel
    
    var body: some View {
        
        ZStack {
            
            NavigationStack {
                
                VStack(spacing: 32) {
                    
                    openFastPaymentsSettingsButton()
                    
                    buttons()
                }
                .alert(
                    item: .init(
                        get: { viewModel.state.alert?.alert },
                        set: { if $0 == nil { viewModel.event(.closeAlert) }}
                    ),
                    content: Alert.init(with:)
                )
                .navigationDestination(
                    item: .init(
                        get: { viewModel.state.destination },
                        set: { if $0 == nil { viewModel.event(.dismissDestination) }}
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
    
    private func buttons() -> some View {
        
        HStack(spacing: 16) {
            
            showLoaderButton()
            showAlertButton()
            showInformerButton()
        }
        .buttonStyle(.bordered)
    }
    
    private func showLoaderButton() -> some View {
        
        Button("loader", action: viewModel.showDemoLoader)
    }
    
    private func showAlertButton() -> some View {
        
        Button("alert", action: viewModel.showDemoAlert)
    }
    
    private func showInformerButton() -> some View {
        
        Button("informer", action: viewModel.showDemoInformer)
    }
    
    @ViewBuilder
    private func loader() -> some View {
        
        ZStack {
            
            Color.black.opacity(0.4)
            
            ProgressView()
        }
        .ignoresSafeArea()
        .opacity(viewModel.state.isLoading ? 1 : 0)
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
                        get: { viewModel.state.alert?.fpsAlert },
                        set: { if $0 == nil { viewModel.event(.closeFPSAlert) }}
                    ),
                    content: Alert.init(with:)
                )
                .navigationDestination(
                    item: .init(
                        get: { viewModel.state.fpsDestination },
                        set: { if $0 == nil { viewModel.event(.dismissFPSDestination) }}
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

// MARK: - Demo Functionality

private extension UserAccountViewModel {
    
    func showDemoAlert() {
        
        event(.demo(.show(.alert)))
    }
    
    func showDemoInformer() {
        
        event(.demo(.show(.informer)))
    }
    
    func showDemoLoader() {
        
        event(.demo(.show(.loader)))
    }
}

struct UserAccountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountView(viewModel: .preview(
            route: .init(),
            getProducts: { .preview },
            createContract: { _, completion in
                
                completion(.success(.active))
            },
            getSettings: { completion in
                
                completion(.active(bankDefault: .offEnabled))
            },
            prepareSetBankDefault: { completion in
                
                completion(.success(()))
            },
            updateContract: { _, completion in
                
                completion(.success(
                    .init(
                        id: .init(generateRandom11DigitNumber()),
                        productID: Product.account.id,
                        contractStatus: .active)
                ))
            },
            updateProduct: { _, completion in
                
                completion(.success(()))
            }
        ))
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
