//
//  PaymentsSuccessViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.03.2022.
//

import SwiftUI
import Combine

struct PaymentsSuccessViewModel {
    
    let header: HeaderViewModel
    let optionButtons: [PaymentsSuccessOptionButtonViewModel]
    let actionButton: ButtonSimpleView.ViewModel
    
    internal init(header: HeaderViewModel,
                  optionButtons: [PaymentsSuccessOptionButtonViewModel],
                  actionButton: ButtonSimpleView.ViewModel) {
        
        self.header = header
        self.optionButtons = optionButtons
        self.actionButton = actionButton
    }
}

extension PaymentsSuccessViewModel {
    
    struct HeaderViewModel {
        
        let stateIcon: Image
        let title: String
        let description: String
        let operatorIcon: Image
        
        internal init(stateIcon: Image, title: String, description: String, operatorIcon: Image) {
            self.stateIcon = stateIcon
            self.title = title
            self.description = description
            self.operatorIcon = operatorIcon
        }
    }
}

class PaymentsSuccessOptionButtonViewModel: Identifiable {
    
    let id: UUID
    let icon: Image
    let title: String
    let action: () -> Void
    
    internal init(id: UUID, icon: Image, title: String, action: @escaping () -> Void) {
        self.id = id
        self.icon = icon
        self.title = title
        self.action = action
    }
}
