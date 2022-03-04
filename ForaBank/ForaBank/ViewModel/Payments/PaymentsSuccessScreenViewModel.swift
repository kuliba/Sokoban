//
//  PaymentsSuccessScreenViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.03.2022.
//

import SwiftUI
import Combine

struct PaymentsSuccessScreenViewModel {
        
        let headerView: PaymentsSuccessOptionHeaderView
        let optionButtons: [PaymentsSuccessOptionButtonViewModel]
        let actionButton: ButtonSimpleView
        
        internal init(headerView: PaymentsSuccessOptionHeaderView,
                      optionButtons: [PaymentsSuccessOptionButtonViewModel],
                      actionButton: ButtonSimpleView) {
            
            self.headerView = headerView
            self.optionButtons = optionButtons
            self.actionButton = actionButton
        }
    
}
