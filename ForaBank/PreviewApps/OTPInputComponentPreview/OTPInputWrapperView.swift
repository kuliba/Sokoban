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
    
    init(demoSettings: DemoSettings) {
        
        let viewModel = TimedOTPInputViewModel(
            demoSettings: demoSettings
        )
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        switch viewModel.state {
        case let .failure(otpFieldFailure):
            Text(String(describing: otpFieldFailure))
                .foregroundStyle(.red)
                .font(.headline)
                .frame(maxHeight: .infinity)
            
        case let .input(input):
            OTPInputView(
                state: input,
                event: viewModel.event
            )
            
        case .validOTP:
            Text("OTP is valid!")
                .foregroundStyle(.green)
                .font(.headline)
                .frame(maxHeight: .infinity)
        }
    }
}

extension TimedOTPInputViewModel {
    
    convenience init(
        demoSettings: DemoSettings
    ) {
        let otpInputViewModel = OTPInputViewModel.default(
            duration: demoSettings.countdownDemoSettings.duration.rawValue,
            initiate: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    switch demoSettings.countdownDemoSettings.initiateResult {
                    case .success:
                        completion(.success(()))
                        
                    case .connectivity:
                        completion(.failure(.connectivityError))
                        
                    case .server:
                        completion(.failure(.serverError("Initiate Server Error")))
                    }
                }
            },
            submitOTP: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(demoSettings.otpFieldDemoSettings.result)
                }
            }
        )
        
        self.init(viewModel: otpInputViewModel, timer: RealTimer())
    }
}

struct OTPInputWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OTPInputWrapperView(
            demoSettings: .shortSuccess
        )
    }
}
