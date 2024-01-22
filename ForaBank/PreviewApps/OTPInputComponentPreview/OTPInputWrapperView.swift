//
//  OTPInputWrapperView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 22.01.2024.
//

import OTPInputComponent
import SwiftUI

struct OTPInputWrapperView: View {
    
    @StateObject private var viewModel: TimedOTPInputViewModel
    
    init(
        confirmWithOTPSettings: ConfirmWithOTPSettings,
        countdownDemoSettings: CountdownDemoSettings,
        otpFieldDemoSettings: DemoSettingsResult
    ) {
        let viewModel = TimedOTPInputViewModel(
            countdownDemoSettings: countdownDemoSettings,
            otpFieldDemoSettings: otpFieldDemoSettings
        )
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        switch viewModel.state {
        case let .failure(otpFieldFailure):
            Text(String(describing: otpFieldFailure))
                .foregroundStyle(.red)
            
        case let .input(input):
            OTPInputView(
                state: input,
                event: viewModel.event
            )
            
        case .validOTP:
            Text("OTP is valid!")
                .foregroundStyle(.green)
        }
    }
}


struct OTPInputWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OTPInputWrapperView(
            confirmWithOTPSettings: .success,
            countdownDemoSettings: .shortSuccess,
            otpFieldDemoSettings: .success)
    }
}
