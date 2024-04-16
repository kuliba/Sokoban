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
                
                openFastPaymentsSettingsButton()
                    .alert(
                        item: .init(
                            get: { viewModel.state.alert },
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
        fpsRoute: UserAccountViewModel.State.FPSRoute
    ) -> some View {
        
        FastPaymentsSettingsWrapperView(
            viewModel: fpsRoute.viewModel,
            config: .preview
        )
        .alert(
            item: .init(
                get: { viewModel.state.destination?.alert },
                // set: { if $0 == nil { viewModel.event(.closeFPSAlert) }}
                // set is called by tapping on alert buttons, that are wired to some actions, no extra handling is needed (not like in case of modal or navigation)
                set: { _ in }
            ),
            content: { .init(with: $0, event: viewModel.event) }
        )
        .navigationDestination(
            item: .init(
                get: { viewModel.state.destination?.destination },
                set: { if $0 == nil { viewModel.event(.dismissFPSDestination) }}
            ),
            destination: fpsDestinationView
        )
    }
    
    @ViewBuilder
    private func fpsDestinationView(
        fpsDestination: UserAccountViewModel.State.FPSDestination
    ) -> some View {
        
        switch fpsDestination {
        case let .confirmSetBankDefault(timedOTPInputViewModel, _):
            OTPInputWrapperView(viewModel: timedOTPInputViewModel)
            
        case let .c2BSub(getC2BSubResponse, _):
            Text("TBD: \(String(describing: getC2BSubResponse))")
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

struct UserAccountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountView(viewModel: .preview(
            state: .init(),
            flowStub: .preview
        ))
    }
}
