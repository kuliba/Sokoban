//
//  File.swift
//  
//
//  Created by Igor Malyarov on 12.02.2024.
//

import UIPrimitives

public struct OTPInputConfig {
    
    let button: ButtonConfig
    let digitModel: DigitModelConfig
    let subtitle: TextConfig
    let timer: TextConfig
    let title: TextConfig
    
    public init(
        button: ButtonConfig,
        digitModel: DigitModelConfig,
        subtitle: TextConfig,
        timer: TextConfig,
        title: TextConfig
    ) {
        self.button = button
        self.digitModel = digitModel
        self.subtitle = subtitle
        self.timer = timer
        self.title = title
    }
}
