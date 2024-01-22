//
//  ContentViewModel.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Foundation

final class ContentViewModel: ObservableObject {
    
    @Published var otpSettings: OTPValidationSettings = .success
    @Published var settings: CountdownDemoSettings = .shortSuccess
    @Published var fullScreenCover: FullScreenCover?
}

extension ContentViewModel {
    
    func updateOTPSettings(
        _ otpSettings: OTPValidationSettings
    ) {
        self.otpSettings = otpSettings
        self.fullScreenCover = nil
    }
    
    func updateCountdownDemoSettings(
        _ settings: CountdownDemoSettings
    ) {
        self.settings = settings
        self.fullScreenCover = nil
    }
}

extension ContentViewModel {
    
    enum FullScreenCover: Identifiable {
        
        case otpSettings
        case countdownSettings
        
        var id: Self { self }
    }
}
