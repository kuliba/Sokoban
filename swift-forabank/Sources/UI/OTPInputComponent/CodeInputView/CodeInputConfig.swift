//
//  CodeInputConfig.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2024.
//

import SwiftUI
import UIPrimitives

public struct CodeInputConfig {
    
    let icon: Image
    let button: ButtonConfig
    let digitModel: DigitModelConfig
    public let resend: ResendConfig
    let subtitle: TextConfig
    let timer: TextConfig
    let title: TextConfig
    
    public init(
        icon: Image,
        button: ButtonConfig,
        digitModel: DigitModelConfig,
        resend: ResendConfig,
        subtitle: TextConfig,
        timer: TextConfig,
        title: TextConfig
    ) {
        self.icon = icon
        self.button = button
        self.digitModel = digitModel
        self.resend = resend
        self.subtitle = subtitle
        self.timer = timer
        self.title = title
    }
}
