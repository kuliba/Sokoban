//
//  TextInputConfig.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import SharedConfigs
import SwiftUI
import TextFieldUI

struct TextInputConfig: Equatable {
    
    let hint: TextConfig
    let imageWidth: CGFloat
    let textFieldConfig: TextFieldConfig
    let title: TextConfig
    let warning: TextConfig
}

extension TextInputConfig {
    
    typealias TextFieldConfig = TextFieldView.TextFieldConfig
}
