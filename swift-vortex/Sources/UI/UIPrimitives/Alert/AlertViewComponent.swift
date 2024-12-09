//
//  AlertViewComponent.swift
//  Vortex
//
//  Created by Max Gribov on 22.02.2022.
//

import Foundation
import SwiftUI

extension Alert {
    
    public struct ViewModel: Identifiable {
        
        public let id = UUID()
        public let title: String
        public let message: String?
        public let primary: ButtonViewModel
        public var secondary: ButtonViewModel? = nil

        public init(
            title: String, 
            message: String?,
            primary: ButtonViewModel,
            secondary: ButtonViewModel? = nil
        ) {
            self.title = title
            self.message = message
            self.primary = primary
            self.secondary = secondary
        }
        
        public struct ButtonViewModel {
            
            public let type: Kind
            public let title: String
            public let action: () -> Void
            
            public init(
                type: Kind, 
                title: String,
                action: @escaping () -> Void
            ) {
                self.type = type
                self.title = title
                self.action = action
            }
            
            public enum Kind {
                
                case `default`
                case distructive
                case cancel
            }
            
        }
    }
    
    public init(with viewModel: ViewModel) {
        
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

public extension Alert {
    
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
