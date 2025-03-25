//
//  TextInputConfig.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 21.03.2025.
//

import Foundation
import TextFieldUI
import UIPrimitives

public struct AmountInputConfig: Equatable {
    
    public let hint: TextConfig
    public let imageWidth: CGFloat
    public let keyboard: KeyboardType
    public let placeholder: String
    public let textField: TextFieldConfig
    public let title: String
    public let titleConfig: TextConfig
    public let toolbar: AmountToolbarConfig
    public let warning: TextConfig
    public let titleOffset: CGFloat
    public let topPadding: CGFloat

    public init(
        hint: TextConfig,
        imageWidth: CGFloat,
        keyboard: KeyboardType,
        placeholder: String,
        textField: TextFieldConfig,
        title: String,
        titleConfig: TextConfig,
        toolbar: AmountToolbarConfig,
        warning: TextConfig,
        titleOffset: CGFloat,
        topPadding: CGFloat
    ) {
        self.hint = hint
        self.imageWidth = imageWidth
        self.keyboard = keyboard
        self.placeholder = placeholder
        self.textField = textField
        self.title = title
        self.titleConfig = titleConfig
        self.toolbar = toolbar
        self.warning = warning
        self.titleOffset = titleOffset
        self.topPadding = topPadding
    }
}

public extension AmountInputConfig {
    
    typealias TextFieldConfig = AmountFieldView.TextFieldConfig
}

public struct AmountToolbarConfig: Equatable {
    
    public let closeImage: String
    public let doneTitle: String
    
    public init(
        closeImage: String,
        doneTitle: String
    ) {
        self.closeImage = closeImage
        self.doneTitle = doneTitle
    }
}
