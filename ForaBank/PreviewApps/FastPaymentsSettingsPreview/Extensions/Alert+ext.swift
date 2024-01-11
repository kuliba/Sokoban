//
//  Alert+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import SwiftUI

extension Alert {
    
    init(with viewModel: AlertViewModel) {
        
        let title = Text(viewModel.title)
        let message = Text(viewModel.message ?? "")
        let primaryButton = Self.button(with: viewModel.primaryButton)
        
        if let secondaryButtonViewModel = viewModel.secondaryButton {
            
            let secondary = Self.button(with: secondaryButtonViewModel)
            
            self.init(title: title, message: message, primaryButton: primaryButton, secondaryButton: secondary)
            
        } else {
            
            self.init(title: title, message: message, dismissButton: primaryButton)
        }
    }
}

extension Alert {
    
    static func button(
        with viewModel: AlertViewModel.ButtonViewModel
    ) -> Alert.Button {
        
        switch viewModel.type {
        case .default:
            return .default(Text(viewModel.title), action: viewModel.action)
            
        case .destructive:
            return .destructive(Text(viewModel.title), action: viewModel.action)
            
        case .cancel:
            return .cancel(Text(viewModel.title), action: viewModel.action)
        }
    }
}
