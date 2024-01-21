//
//  ContentViewModel.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Foundation

final class ContentViewModel: ObservableObject {
    
    @Published var countdownDemoSettings: CountdownDemoSettings = .shortSuccess
    @Published var otpFieldDemoSettings: OTPFieldDemoSettings = .success
    @Published var fullScreenCover: FullScreenCover?
}

extension ContentViewModel {
    
    func updateOTPSettings(
        _ otpFieldDemoSettings: OTPFieldDemoSettings
    ) {
        self.otpFieldDemoSettings = otpFieldDemoSettings
        self.fullScreenCover = nil
    }
    
    func updateCountdownDemoSettings(
        _ settings: CountdownDemoSettings
    ) {
        self.countdownDemoSettings = settings
        self.fullScreenCover = nil
    }
}

extension ContentViewModel {
    
    enum FullScreenCover: Identifiable {
        
        case countdownDemoSettings
        case otpFieldDemoSettings
        
        var id: Self { self }
    }
}
