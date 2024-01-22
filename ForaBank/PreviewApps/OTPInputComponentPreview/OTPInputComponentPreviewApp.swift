//
//  OTPInputComponentPreviewApp.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

@main
struct OTPInputComponentPreviewApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(viewModel: .init(
                makeTimedOTPInputViewModel: {
                    
                    .init(
                        countdownDemoSettings: $0,
                        otpFieldDemoSettings: $1
                    )
                }
            ))
            //            OTPInputView()
        }
    }
}

extension TimedOTPInputViewModel {
    
    convenience init(
        countdownDemoSettings: CountdownDemoSettings,
        otpFieldDemoSettings: DemoSettingsResult
    ) {
        let otpInputViewModel = OTPInputViewModel.default(
            initiate: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    switch countdownDemoSettings.initiateResult {
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
                    
                    completion(otpFieldDemoSettings.result)
                }
            }
        )
        
        self.init(viewModel: otpInputViewModel, timer: RealTimer())
    }
}
