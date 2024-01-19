//
//  CountdownViewDemo.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

struct CountdownViewDemo: View {
    
    @State private var otpSettings: OTPSettings = .success
    @State private var settings: CountdownDemoSettings = .shortSuccess
    @State private var isShowingSettingsOptions = false
    
    var body: some View {
        
        VStack(spacing: 64) {
            
            OTPInputView(viewModel: .preview(
                otpSettings.result
            ))
            
            CountdownView(settings: settings)
        }
        .padding(.top, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .topTrailing, content: buttons)
        .fullScreenCover(
            isPresented: $isShowingSettingsOptions,
            content: fullScreenCover
        )
    }
    
    private func buttons() -> some View {
        
        HStack {
            
            optionsButton()
            otpOptionsButton()
        }
        .padding(.horizontal)
    }
    
    private func otpOptionsButton() -> some View {
        
        Button {
            isShowingSettingsOptions = true
        } label: {
            Image(systemName: "checkmark.circle.badge.questionmark")
        }
    }
    
    private func optionsButton() -> some View {
        
        Button {
            isShowingSettingsOptions = true
        } label: {
            Image(systemName: "timer")
        }
    }
    
    private func fullScreenCover() -> some View {
        
        NavigationView {
            
            CountdownDemoSettingsView(
                settings: settings,
                apply: {
                    
                    settings = $0
                    isShowingSettingsOptions = false
                }
            )
            .navigationTitle("Countdown Options")
            .navigationBarTitleDisplayMode(.inline)
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
        
        CountdownViewDemo()
    }
}
