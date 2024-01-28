//
//  UserAccountView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import FastPaymentsSettings
import OTPInputComponent
import SwiftUI
import UIPrimitives
import UserAccountNavigationComponent

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
                        get: { viewModel.alert },
                        set: { if $0 == nil { viewModel.event(.closeAlert) }}
                    ),
                    content: { .init(with: $0, event: viewModel.event) }
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
        destination: UserAccountViewModel.State.Destination
    ) -> some View {
        
        switch destination {
        case let .fastPaymentsSettings(fps):
            FastPaymentsSettingsWrapperView(
                viewModel: fps.viewModel,
                config: .default
            )
            .alert(
                item: .init(
                    get: { viewModel.state.fpsRoute?.alert },
                    // set: { if $0 == nil { viewModel.event(.closeFPSAlert) }}
                    // set is called by tapping on alert buttons, that are wired to some actions, no extra handling is needed (not like in case of modal or navigation)
                    set: { _ in }
                ),
                content: { .init(with: $0, event: viewModel.event) }
            )
            .navigationDestination(
                item: .init(
                    get: { viewModel.state.fpsRoute?.destination },
                    set: { if $0 == nil { viewModel.event(.dismissFPSDestination) }}
                ),
                destination: fpsDestinationView
            )
        }
    }
    
    @ViewBuilder
    private func fpsDestinationView(
        fpsDestination: UserAccountViewModel.State.Destination.FPSDestination
    ) -> some View {
        
        switch fpsDestination {
        case let .confirmSetBankDefault(timedOTPInputViewModel, _):
            OTPInputWrapperView(viewModel: timedOTPInputViewModel)
            
        case let .c2BSub(getC2BSubResponse, _):
            Text("TBD: \(String(describing: getC2BSubResponse))")
        }
    }
}

private extension UserAccountViewModel {
    
    var alert: AlertModelOf<Event>? {
        
        if case let .alert(alert) = state.alert {
            return alert
        } else {
            return nil
        }
    }
}

struct OTPInputWrapperView: View {
    
    @ObservedObject private var viewModel: TimedOTPInputViewModel
    
    init(viewModel: TimedOTPInputViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        switch viewModel.state {
        case .failure:
            EmptyView()
            
        case let .input(input):
            OTPInputView(
                state: input,
                phoneNumber: "TBD: hardcoded phone number",
                event: viewModel.event(_:)
            )
            
        case .validOTP:
            EmptyView()
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
            state: .init(),
            flowStub: .preview
        ))
    }
}
