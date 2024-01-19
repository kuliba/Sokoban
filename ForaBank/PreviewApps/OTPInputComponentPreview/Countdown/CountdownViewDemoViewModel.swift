//
//  CountdownViewDemoViewModel.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Foundation

final class CountdownViewDemoViewModel: ObservableObject {
    
    @Published var otpSettings: OTPSettings = .success
    @Published var settings: CountdownDemoSettings = .shortSuccess
    @Published var fullScreenCover: FullScreenCover?
}

extension CountdownViewDemoViewModel {
    
    func updateOTPSettings(
        _ otpSettings: OTPSettings
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

extension CountdownViewDemoViewModel {
    
    enum FullScreenCover: Identifiable {
        
        case otpSettings
        case countdownSettings
        
        var id: Self { self }
    }
}
