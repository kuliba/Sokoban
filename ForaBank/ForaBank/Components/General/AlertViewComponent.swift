//
//  AlertViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 22.02.2022.
//

import Foundation
import SwiftUI

extension Alert {
    
    struct ViewModel: Identifiable {
        
        let id = UUID()
        let title: String
        let message: String? 
        let primary: ButtonViewModel
        var secondary: ButtonViewModel? = nil

        struct ButtonViewModel {
            
            let type: Kind
            let title: String
            let action: () -> Void
            
            enum Kind {
                
                case `default`
                case distructive
                case cancel
            }
            
        }
    }
    
    init(with viewModel: ViewModel) {
        
        let title = Text(viewModel.title)
        let message = Text(viewModel.message ?? "")
        let primaryButton = Self.button(with: viewModel.primary)
        
        if let secondaryButtonViewModel = viewModel.secondary {
            
            let secondary = Self.button(with: secondaryButtonViewModel)
            
            self.init(title: title, message: message, primaryButton: primaryButton, secondaryButton: secondary)
            
        } else {
            
            self.init(title: title, message: message, dismissButton: primaryButton)
        }
    }
}

extension Alert {
    
    static func button(with viewModel: Alert.ViewModel.ButtonViewModel) -> Alert.Button {
        
        switch viewModel.type {
        case .default:
            return .default(Text(viewModel.title), action: viewModel.action)
            
        case .distructive:
            return .destructive(Text(viewModel.title), action: viewModel.action)
            
        case .cancel:
            return .cancel(Text(viewModel.title), action: viewModel.action)
        }
    }
}

extension Alert.ViewModel {
    
    static func techError(
        message: String = "Возникла техническая ошибка",
        primaryAction: @escaping () -> Void
    ) -> Self {
        
        .init(
            title: "Ошибка",
            message: message,
            primary: .init(
                type: .default,
                title: "OK",
                action: primaryAction
            )
        )
    }
}

extension Alert.ViewModel {
    
    static func dataUpdateFailure(
        message: String = .updateInfoText,
        primaryAction: @escaping () -> Void
    ) -> Self {
        
        .init(
            title: "Ошибка",
            message: message,
            primary: .init(
                type: .default,
                title: "OK",
                action: primaryAction
            )
        )
    }
}
