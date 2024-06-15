//
//  TimedOTPInputViewConfig.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SharedConfigs
import SwiftUI

public struct TimedOTPInputViewConfig: Equatable {
    
    let otp: TextConfig
    let resend: ResendConfig
    let timer: TimerConfig
    let title: TitleConfig
    
    public init(
        otp: TextConfig,
        resend: ResendConfig,
        timer: TimerConfig,
        title: TitleConfig
    ) {
        self.otp = otp
        self.resend = resend
        self.timer = timer
        self.title = title
    }
}

extension TimedOTPInputViewConfig {
    
    public struct ResendConfig: Equatable {
        
        let text: String
        let backgroundColor: Color
        let config: TextConfig
        
        public init(
            text: String,
            backgroundColor: Color,
            config: TextConfig
        ) {
            self.text = text
            self.backgroundColor = backgroundColor
            self.config = config
        }
    }
    
    public struct TimerConfig: Equatable {
        
        let backgroundColor: Color
        let config: TextConfig
        
        public init(
            backgroundColor: Color,
            config: TextConfig
        ) {
            self.backgroundColor = backgroundColor
            self.config = config
        }
    }
}
