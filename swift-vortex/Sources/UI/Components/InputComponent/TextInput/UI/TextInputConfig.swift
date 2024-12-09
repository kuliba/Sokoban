//
//  TextInputConfig.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import SharedConfigs
import SwiftUI
import TextFieldUI

public struct TextInputConfig: Equatable {
    
    public let hint: TextConfig
    public let imageWidth: CGFloat
    public let keyboard: KeyboardType
    public let placeholder: String
    public let textField: TextFieldConfig
    public let title: String
    public let titleConfig: TextConfig
    public let toolbar: ToolbarConfig
    public let warning: TextConfig
    
    public init(
        hint: TextConfig,
        imageWidth: CGFloat,
        keyboard: KeyboardType,
        placeholder: String,
        textField: TextFieldConfig,
        title: String,
        titleConfig: TextConfig,
        toolbar: ToolbarConfig,
        warning: TextConfig
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
    }
}

public extension TextInputConfig {
    
    typealias TextFieldConfig = TextFieldView.TextFieldConfig
}

public struct ToolbarConfig: Equatable {
    
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
