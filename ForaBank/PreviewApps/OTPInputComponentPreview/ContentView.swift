//
//  ContentView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel: ContentViewModel
    
    init(viewModel: ContentViewModel) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        ZStack {
            
            list()
            
            spinner()
                .ignoresSafeArea()
        }
    }
    
    private func list() -> some View {
        
        List {
            
            confirmWithOTPButton()
                .listSectionSeparator(.hidden)
            
            settings()
        }
        .listStyle(.plain)
        .padding(.top, 64)
        .alert(
            item: .init(
                get: { viewModel.alert },
                set: { if $0 == nil { viewModel.resetModal() }}
            ),
            content: alert
        )
        .fullScreenCover(
            item: .init(
                get: { viewModel.fullScreenCover },
                set: { if $0 == nil { viewModel.resetModal() }}
            ),
            content: fullScreenCover
        )
        .overlay(alignment: .center, content: informer)
    }
    
    private func settings() -> some View {
        
        Group {
            
            PickerSection(
                title: "Confirm with OTP Result",
                selection: .init(
                    get: { viewModel.demoSettings.confirmWithOTPSettings },
                    set: viewModel.updateConfirmWithOTPSettings(_:)
                )
            )
            
            if viewModel.demoSettings.confirmWithOTPSettings.isSuccess {
                
                PickerSection(
                    title: "Countdown Duration (sec)",
                    selection: .init(
                        get: { viewModel.demoSettings.countdownDemoSettings.duration },
                        set: viewModel.updateCountdownDemoDuration(_:)
                    )
                )
                
                PickerSection(
                    title: "Initiate Countdown Result",
                    selection: .init(
                        get: { viewModel.demoSettings.countdownDemoSettings.initiateResult },
                        set: viewModel.updateCountdownDemoInitiateResult(_:)
                    )
                )
                
                PickerSection(
                    title: "OTP Validation Result",
                    selection: .init(
                        get: { viewModel.demoSettings.otpFieldDemoSettings },
                        set: viewModel.updateOTPFieldDemoSettings
                    )
                )
            }
        }
    }
    
    private func confirmWithOTPButton() -> some View {
        
        Button("Confirm with OTP", action: viewModel.confirmWithOTP)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func alert(
        alert: ContentViewModel.Modal.Alert
    ) -> Alert {
        
        .init(title: Text("Error"), message: Text(alert.message))
    }
    
    @ViewBuilder
    private func fullScreenCover(
        _ fullScreenCover: ContentViewModel.Modal.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
        case .confirmWithOTP:
            NavigationView {
                
                confirmWithOTP()
            }
        }
    }
    
    private func confirmWithOTP() -> some View {
        
        OTPInputWrapperView(
            demoSettings: viewModel.demoSettings
        )
        .padding(.top, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: viewModel.resetModal) {
                    
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
    
    @ViewBuilder
    private func informer() -> some View {
        
        viewModel.informer.map {
            
            Text($0.message)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
        }
    }
    
    private func spinner() -> some View {
        
        ZStack {
            
            Color.green.opacity(0.4)
            
            ProgressView()
        }
        .opacity(viewModel.isShowingSpinner ? 1 : 0)
    }
}

extension DemoSettingsResult: PickerDisplayable {}
extension CountdownDemoSettings.Duration: PickerDisplayable {}
extension CountdownDemoSettings.InitiateResult: PickerDisplayable {}

private extension DemoSettingsResult {
    
    var isSuccess: Bool {
        
        if case .success = self {
            return true
        } else {
            return false
        }
    }
}

private extension ContentViewModel {
    
    var alert: Modal.Alert? {
        
        guard case let .alert(alert) = modal else {
            
            return nil
        }
        
        return alert
    }
    
    var fullScreenCover: Modal.FullScreenCover? {
        
        guard case let .fullScreenCover(fullScreenCover) = modal else {
            
            return nil
        }
        
        return fullScreenCover
    }
    
    var informer: Modal.Informer? {
        
        guard case let .informer(informer) = modal else {
            
            return nil
        }
        
        return informer
    }
    
    var isShowingSpinner: Bool {
        
        if case .spinner = modal {
            return true
        } else {
            return false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView(viewModel: .init())
    }
}
