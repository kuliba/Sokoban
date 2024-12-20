//
//  Alert+ext.swift
//  
//
//  Created by Igor Malyarov on 11.01.2024.
//

import SwiftUI

public extension Alert {
    
    init<Event>(
        with viewModel: AlertModelOf<Event>,
        event: @escaping (Event) -> Void
    ) {
        let title = Text(viewModel.title)
        let message = Text(viewModel.message ?? "")
        let primaryButton = Self.button(with: viewModel.primaryButton, event: event)
        
        if let secondary = viewModel.secondaryButton {
            
            let secondaryButton = Self.button(with: secondary, event: event)
            
            self.init(title: title, message: message, primaryButton: primaryButton, secondaryButton: secondaryButton)
            
        } else {
            
            self.init(title: title, message: message, dismissButton: primaryButton)
        }
    }
    
    static func button<Event>(
        with viewModel: ButtonViewModel<Event>,
        event: @escaping (Event) -> Void
    ) -> Alert.Button {
        
        switch viewModel.type {
        case .default:
            return .default(
                Text(viewModel.title),
                action: { event(viewModel.event) }
            )
            
        case .destructive:
            return .destructive(
                Text(viewModel.title),
                action: { event(viewModel.event) }
            )
            
        case .cancel:
            return .cancel(
                Text(viewModel.title),
                action: { event(viewModel.event) }
            )
        }
    }
}
