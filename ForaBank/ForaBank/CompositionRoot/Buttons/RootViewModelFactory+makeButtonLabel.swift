//
//  RootViewModelFactory+makeButtonLabel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2023.
//

import SwiftUI

extension RootViewModelFactory {
    
    func makeSuccessButtonLabel(
        option: Payments.ParameterSuccessOptionButtons.Option
    ) -> some View {
        
        PaymentsSuccessOptionButtonsView.ButtonView.ButtonLabel(
            title: option.title,
            icon: option.icon
        )
    }
}
