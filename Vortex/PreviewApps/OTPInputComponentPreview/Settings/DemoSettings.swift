//
//  DemoSettings.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 22.01.2024.
//

struct DemoSettings {
    
    let phoneNumber: String
    var confirmWithOTPSettings: ConfirmWithOTPSettings
    var countdownDemoSettings: CountdownDemoSettings
    var otpFieldDemoSettings: DemoSettingsResult
}

typealias ConfirmWithOTPSettings = DemoSettingsResult
