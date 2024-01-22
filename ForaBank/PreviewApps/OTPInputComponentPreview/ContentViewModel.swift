//
//  ContentViewModel.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Foundation
import OTPInputComponent

final class ContentViewModel: ObservableObject {
    
    typealias MakeTimedOTPInputViewModel = (CountdownDemoSettings, OTPFieldDemoSettings) -> TimedOTPInputViewModel

    @Published var countdownDemoSettings: CountdownDemoSettings = .shortSuccess
    @Published var otpFieldDemoSettings: OTPFieldDemoSettings = .success
    @Published var fullScreenCover: FullScreenCover?
    
    private let makeTimedOTPInputViewModel: MakeTimedOTPInputViewModel
    
    init(makeTimedOTPInputViewModel: @escaping MakeTimedOTPInputViewModel) {

        self.makeTimedOTPInputViewModel = makeTimedOTPInputViewModel
    }
}

extension ContentViewModel {
    
    func confirmWithOTP() {
        
        fullScreenCover = .confirmWithOTP
    }
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
        
        case confirmWithOTP
        case countdownDemoSettings
        case otpFieldDemoSettings
        
        var id: Self { self }
    }
}
