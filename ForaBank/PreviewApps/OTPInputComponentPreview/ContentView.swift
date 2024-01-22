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
            
            Color.clear
            
            Button("Confirm with OTP", action: viewModel.confirmWithOTP)
                .buttonStyle(.borderedProminent)
        }
        .overlay(alignment: .topTrailing, content: buttons)
        .fullScreenCover(
            item: .init(
                get: { viewModel.fullScreenCover },
                set: { if $0 == nil { viewModel.resetFullScreenCover() }}
            ),
            content: fullScreenCover
        )
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
    
    private func buttons() -> some View {
        
        HStack {
            
            countdownOptionsButton()
            otpOptionsButton()
        }
        .padding(.horizontal)
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
