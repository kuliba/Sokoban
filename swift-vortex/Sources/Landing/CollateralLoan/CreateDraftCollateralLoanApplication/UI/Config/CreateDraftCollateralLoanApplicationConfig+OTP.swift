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
        public let iconColor: Color
        public let timerDuration: Int
        public let warningText: TextConfig
        public let view: TimedOTPInputViewConfig
        
        public init(
            otpLength: Int,
            smsIcon: Image,
            iconColor: Color,
            timerDuration: Int,
            warningText: TextConfig,
            view: TimedOTPInputViewConfig
        ) {
            self.otpLength = otpLength
            self.smsIcon = smsIcon
            self.iconColor = iconColor
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
        iconColor: .secondary,
        timerDuration: 60,
        warningText: .init(textFont: Font.system(size: 14), textColor: .red),
        view: .preview
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
