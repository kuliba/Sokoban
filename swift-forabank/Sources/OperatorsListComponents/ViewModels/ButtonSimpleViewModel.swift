//
//  ButtonSimpleViewModel.swift
//
//
//  Created by Дмитрий Савушкин on 12.02.2024.
//

import Foundation
import SwiftUI

public final class ButtonSimpleViewModel: Identifiable {
    
    public let id: UUID
    let title: String
    let action: () -> Void

    let buttonConfiguration: ButtonConfiguration
    
    public init(
        id: UUID = UUID(),
        title: String,
        buttonConfiguration: ButtonConfiguration,
        action: @escaping () -> Void
    ) {

        self.id = id
        self.title = title
        self.action = action
        self.buttonConfiguration = buttonConfiguration
    }
    
    public struct ButtonConfiguration {
    
        let titleFont: Font
        let titleForeground: Color
        let backgroundColor: Color
        
        public init(
            titleFont: Font,
            titleForeground: Color,
            backgroundColor: Color
        ) {
            self.titleFont = titleFont
            self.titleForeground = titleForeground
            self.backgroundColor = backgroundColor
        }
    }
}
