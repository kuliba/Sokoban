//
//  CreateDraftCollateralLoanApplicationConfig+OTP.swift
//  
//
//  Created by Valentin Ozerov on 30.01.2025.
//

import Combine
import OTPInputComponent
import SwiftUI
import UIPrimitives

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct OTP {
                
        public let otpLength: Int
        public let smsIcon: Image
        public let timerDuration: Int
        public let warningText: TextConfig
        public let view: TimedOTPInputViewConfig
        
        public init(
            otpLength: Int,
            smsIcon: Image,
            timerDuration: Int,
            warningText: TextConfig,
            view: TimedOTPInputViewConfig
        ) {
            self.otpLength = otpLength
            self.smsIcon = smsIcon
            self.timerDuration = timerDuration
            self.warningText = warningText
            self.view = view
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig.OTP {
    
    static let preview = Self(
        otpLength: 6,
        smsIcon: .smsImage,
        timerDuration: 60,
        warningText: .init(textFont: Font.system(size: 14), textColor: .red),
        view: .default
    )
}

extension UIPrimitives.AsyncImage {
    
    static let smsImage = Self(
        image: .smsImage,
        publisher: Just(.smsImage).eraseToAnyPublisher()
    )
}

extension Image {
    
    static var smsImage: Image {
        Image("ic24SmsCode")
    }
}

extension TimedOTPInputViewConfig {
    
    static let `default` = Self(
        otp: .init(
            textFont: .headline,
            textColor: .primary
        ),
        resend: .default,
        timer: .default,
        title: .default
    )
}

extension TimedOTPInputViewConfig.ResendConfig {
    
    static let `default` = Self(
        text: "Отправить повторно",
        backgroundColor: .white,
        config: .init(
            textFont: .caption,
            textColor: .primary
        )
    )
}

extension TimedOTPInputViewConfig.TimerConfig {
    
    static let `default` = Self(
        backgroundColor: .clear,
        config: .init(
            textFont: .subheadline.bold(),
            textColor: .red
        )
    )
}

extension TitleConfig {
    
    static let `default` = Self(
        text: "Введите код",
        config: .init(
            textFont: .subheadline,
            textColor: .secondary
        )
    )
}
