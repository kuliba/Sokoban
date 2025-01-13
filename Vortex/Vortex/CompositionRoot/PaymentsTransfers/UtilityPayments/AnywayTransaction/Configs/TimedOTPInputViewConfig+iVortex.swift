//
//  TimedOTPInputViewConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.06.2024.
//

import OTPInputComponent

extension TimedOTPInputViewConfig {
    
    static let iVortex: Self = .init(
        otp: .init(
            textFont: .textH4M16240(),
            textColor: .textSecondary
        ),
        resend: .init(
            text: "Отправить повторно",
            backgroundColor: .mainColorsWhite,
            config: .init(
                textFont: .textBodyMR14180(),
                textColor: .textSecondary
            )
        ),
        timer: .init(
            backgroundColor: .mainColorsWhite,
            config: .init(
                textFont: .textBodyMR14180(),
                textColor: .textRed
            )
        ),
        title: .init(
            text: "Введите код",
            config: .init(
                textFont: .textBodyMR14180(),
                textColor: .textPlaceholder
            )
        )
    )
}
