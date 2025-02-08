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
            textColor: .primary
        ),
        resend: .preview,
        timer: .preview,
        title: .preview
    )
}

extension TimedOTPInputViewConfig.ResendConfig {
    
    static let preview = Self(
        text: "Отправить повторно",
        backgroundColor: .white,
        config: .init(
            textFont: .caption,
            textColor: .primary
        )
    )
}

extension TimedOTPInputViewConfig.TimerConfig {
    
    static let preview = Self(
        backgroundColor: .clear,
        config: .init(
            textFont: .subheadline.bold(),
            textColor: .red
        )
    )
}

extension TitleConfig {
    
    static let preview = Self(
        text: "Введите код",
        config: .init(
            textFont: .subheadline,
            textColor: .secondary
        )
    )
}
