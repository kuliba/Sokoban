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
        public let smsIcon: IconView
        public let timerDuration: Int
        public let view: TimedOTPInputViewConfig
        
        public init(
            otpLength: Int,
            smsIcon: IconView,
            timerDuration: Int,
            view: TimedOTPInputViewConfig
        ) {
            self.otpLength = otpLength
            self.smsIcon = smsIcon
            self.timerDuration = timerDuration
            self.view = view
        }
    }
    
    public typealias IconView = UIPrimitives.AsyncImage
}

extension CreateDraftCollateralLoanApplicationConfig.OTP {
    
    static let preview = Self(
        otpLength: 6,
        smsIcon: .smsImage,
        timerDuration: 60,
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
        Image(imageData: .named("ic24SmsCode"))
    }
}
