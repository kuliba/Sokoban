//
//  ButtonSimpleViewModel.swift
//
//
//  Created by Дмитрий Савушкин on 12.02.2024.
//

import Foundation
import SwiftUI

public final class ButtonSimpleViewModel: ObservableObject, Identifiable {
    
    public let id = UUID()
    @Published var title: String
    let action: () -> Void

    let buttonConfiguration: ButtonConfiguration
    
    struct ButtonConfiguration {
    
        let titleFont: Font
        let titleForeground: Color
    }
    
    internal init(
        title: String,
        buttonConfiguration: ButtonConfiguration,
        action: @escaping () -> Void
    ) {

        self.title = title
        self.action = action
        self.buttonConfiguration = buttonConfiguration
    }
}
