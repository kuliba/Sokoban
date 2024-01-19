//
//  CountdownViewDemo.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

struct CountdownViewDemo: View {
    
    @StateObject private var viewModel: CountdownViewDemoViewModel
    
    init(viewModel: CountdownViewDemoViewModel) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        VStack(spacing: 64) {
            
            OTPInputView(viewModel: .preview(
                viewModel.otpSettings.result
            ))
            
            CountdownView(settings: viewModel.settings)
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
            viewModel.fullScreenCover = .otpSettings
        } label: {
            Image(systemName: "checkmark.circle.badge.questionmark")
        }
    }
    
    private func countdownOptionsButton() -> some View {
        
        Button {
            viewModel.fullScreenCover = .countdownSettings
        } label: {
            Image(systemName: "timer")
        }
    }
    
    @ViewBuilder
    private func fullScreenCover(
        _ fullScreenCover: CountdownViewDemoViewModel.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
        case .countdownSettings:
            NavigationView {
                
                CountdownDemoSettingsView(
                    settings: viewModel.settings,
                    apply: viewModel.updateCountdownDemoSettings
                )
                .navigationTitle("Countdown Options")
                .navigationBarTitleDisplayMode(.inline)
            }
            
        case .otpSettings:
            NavigationView {
                
                Button("OTP Validation Options") {
                    viewModel.updateOTPSettings(viewModel.otpSettings)
                }
                .navigationTitle("OTP Validation Options")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

extension OTPInputViewModel {
    
    static func `default`(
        submitOTP: @escaping OTPInputEffectHandler.SubmitOTP,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> OTPInputViewModel {
        
        let reducer = OTPInputReducer()
        let effectHandler = OTPInputEffectHandler(submitOTP: submitOTP)
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

struct CountdownViewDemo_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CountdownViewDemo(viewModel: .init())
    }
}
