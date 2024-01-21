//
//  ContentView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel: ContentViewModel
    
    init(viewModel: ContentViewModel) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        VStack(spacing: 64) {
            
            OTPInputFieldView(viewModel: .preview(
                viewModel.otpFieldDemoSettings.result
            ))
            
            CountdownView(settings: viewModel.countdownDemoSettings)
        }
        .padding(.top, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .topTrailing, content: buttons)
        .fullScreenCover(
            item: $viewModel.fullScreenCover,
            content: fullScreenCover
        )
    }
    
    private func buttons() -> some View {
        
        HStack {
            
            countdownOptionsButton()
            otpOptionsButton()
        }
        .padding(.horizontal)
    }
    
    private func otpOptionsButton() -> some View {
        
        Button {
            viewModel.fullScreenCover = .otpFieldDemoSettings
        } label: {
            Image(systemName: "checkmark.circle.badge.questionmark")
        }
    }
    
    private func countdownOptionsButton() -> some View {
        
        Button {
            viewModel.fullScreenCover = .countdownDemoSettings
        } label: {
            Image(systemName: "timer")
        }
    }
    
    @ViewBuilder
    private func fullScreenCover(
        _ fullScreenCover: ContentViewModel.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
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
        
        ContentView(viewModel: .init())
    }
}
