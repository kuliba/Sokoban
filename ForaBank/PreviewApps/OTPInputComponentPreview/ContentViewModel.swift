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

    @Published private(set) var countdownDemoSettings: CountdownDemoSettings = .shortSuccess
    @Published private(set) var otpFieldDemoSettings: OTPFieldDemoSettings = .success
    @Published private(set) var fullScreenCover: FullScreenCover?
    
    private let makeTimedOTPInputViewModel: MakeTimedOTPInputViewModel
    
    init(makeTimedOTPInputViewModel: @escaping MakeTimedOTPInputViewModel) {

        self.makeTimedOTPInputViewModel = makeTimedOTPInputViewModel
    }
}

extension ContentViewModel {
    
    func confirmWithOTP() {
        
        fullScreenCover = .confirmWithOTP
    }
    
    func showCountdownOptions() {
        
        fullScreenCover = .countdownDemoSettings
    }
    
    func showOTPFieldDemoSettings() {
        
        fullScreenCover = .otpFieldDemoSettings
    }
    
    func resetFullScreenCover() {
        
        fullScreenCover = nil
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
