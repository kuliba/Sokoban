//
//  AlertViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Foundation

struct AlertViewModel: Identifiable {
    
    let id = UUID()
    let title: String
    let message: String?
    let primaryButton: ButtonViewModel
    let secondaryButton: ButtonViewModel?
    
    struct ButtonViewModel {
        
        let type: ButtonType
        let title: String
        let action: () -> Void
        
        enum ButtonType {
            
            case `default`, destructive, cancel
        }
    }
}

extension AlertViewModel {
    
    init(
        title: String,
        primaryButton: ButtonViewModel
    ) {
        self.init(title: title, message: nil, primaryButton: primaryButton, secondaryButton: nil)
    }
}
