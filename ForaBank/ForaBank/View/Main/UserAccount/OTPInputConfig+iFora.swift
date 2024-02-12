//
//  OTPInputConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.02.2024.
//

import OTPInputComponent

extension OTPInputConfig {
    
    static let iFora: Self = .init(
        button: .iFora,
        digitModel: .init(
            digitConfig: .init(
                textFont: .textH0B32402(),
                textColor: .textPlaceholder
            ), 
            rectColor: .mainColorsGrayMedium
        ),
        resend: .init(
            backgroundColor: .buttonSecondary,
            text: .init(
                textFont: .textBodySR12160(),
                textColor: .textRed
            )
        ),
        subtitle: .init(
            textFont: .textBodyMR14200(),
            textColor: .textPlaceholder
        ),
        timer: .init(
            textFont: .textH3R18240(),
            textColor: .textSecondary
        ),
        title: .init(
            textFont: .textH3Sb18240(),
            textColor: .textSecondary
        )
    )
}
