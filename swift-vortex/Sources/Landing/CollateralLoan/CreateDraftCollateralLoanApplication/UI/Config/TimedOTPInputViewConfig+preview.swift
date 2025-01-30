//
//  CreateDraftCollateralLoanApplicationConfig+OTP.swift
//
//
//  Created by Valentin Ozerov on 30.01.2025.
//

import OTPInputComponent
import SharedConfigs
import SwiftUI

extension TimedOTPInputViewConfig {
    
    static let preview = Self(
        otp: .init(
            textFont: .headline,
            textColor: .orange
        ),
        resend: .preview,
        timer: .preview,
        title: .preview
    )
}

extension TimedOTPInputViewConfig.ResendConfig {
    
    static let preview = Self(
        text: "Отправить повторно",
        backgroundColor: .blue.opacity(0.1),
        config: .init(
            textFont: .caption,
            textColor: .blue
        )
    )
}

extension TimedOTPInputViewConfig.TimerConfig {
    
    static let preview = Self(
        backgroundColor: .pink,
        config: .init(
            textFont: .subheadline.bold(),
            textColor: .yellow
        )
    )
}

extension TitleConfig {
    
    static let preview = Self(
        text: "Введите код",
        config: .init(
            textFont: .subheadline,
            textColor: .green
        )
    )
}
