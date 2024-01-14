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

extension AlertViewModel: Equatable {
    
    static func == (lhs: AlertViewModel, rhs: AlertViewModel) -> Bool {
        
        lhs.id == rhs.id
    }
}

extension AlertViewModel {
    
    init(
        title: String = "",
        message: String? = nil,
        primaryButton: ButtonViewModel
    ) {
        self.init(title: title, message: message, primaryButton: primaryButton, secondaryButton: nil)
    }
}
