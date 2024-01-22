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
            
            confirmWithOTPButton()
                .fullScreenCover(
                    item: .init(
                        get: { viewModel.fullScreenCover },
                        set: { if $0 == nil { viewModel.resetFullScreenCover() }}
                    ),
                    content: fullScreenCover
                )
            
            spinner()
        }
    }
    
    private func confirmWithOTPButton() -> some View {
        
        Button("Confirm with OTP", action: viewModel.confirmWithOTP)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topTrailing, content: buttons)
    }
    
    private func spinner() -> some View {
        
        ZStack {
            
            Color.black.opacity(0.2)
            
            ProgressView()
        }
        .opacity(viewModel.isShowingSpinner ? 1 : 0)
    }
    
    private func buttons() -> some View {
        
        HStack {
            
            confirmWithOTPOptionsButton()
            countdownOptionsButton()
            otpOptionsButton()
        }
        .padding(.horizontal)
    }
    
    private func confirmWithOTPOptionsButton() -> some View {
        
        Button(action: viewModel.showConfirmWithOTPSettings) {
            
            Image(systemName: "checkmark.circle.badge.questionmark")
        }
    }
    
    private func otpOptionsButton() -> some View {
        
        Button(action: viewModel.showOTPFieldDemoSettings) {
            
            Image(systemName: "checkmark.circle.badge.questionmark")
        }
    }
    
    private func countdownOptionsButton() -> some View {
        
        Button(action: viewModel.showCountdownOptions) {
            
            Image(systemName: "timer")
        }
    }
    
    @ViewBuilder
    private func fullScreenCover(
        _ fullScreenCover: ContentViewModel.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
        case .confirmWithOTP:
            confirmWithOTP()
            
        case let .settings(settings):
            switch settings {
            case .confirmWithOTPSettings:
                NavigationView {
                    
                    OTPFieldDemoSettingsView(
                        otpSettings: viewModel.confirmWithOTPSettings,
                        apply: viewModel.updateConfirmWithOTPSettings
                    )
                    .navigationTitle("Confirm OTP Options")
                    .navigationBarTitleDisplayMode(.inline)
                }
                
            case .countdownDemoSettings:
                NavigationView {
                    
                    CountdownDemoSettingsView(
                        settings: viewModel.countdownDemoSettings,
                        apply: viewModel.updateCountdownDemoSettings
                    )
                    .navigationTitle("Countdown Options")
                    .navigationBarTitleDisplayMode(.inline)
                }
                
            case .otpFieldDemoSettings:
                NavigationView {
                    
                    OTPFieldDemoSettingsView(
                        otpSettings: viewModel.otpFieldDemoSettings,
                        apply: viewModel.updateOTPSettings
                    )
                    .navigationTitle("OTP Validation Options")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    private func confirmWithOTP() -> some View {
        
        VStack(spacing: 64) {
            
            OTPInputFieldView(viewModel: .preview(
                viewModel.otpFieldDemoSettings.result
            ))
            
            CountdownView(settings: viewModel.countdownDemoSettings)
        }
        .padding(.top, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView(viewModel: .init(
            makeTimedOTPInputViewModel: {
                
                .init(
                    countdownDemoSettings: $0,
                    otpFieldDemoSettings: $1
                )
            }
        ))
    }
}
