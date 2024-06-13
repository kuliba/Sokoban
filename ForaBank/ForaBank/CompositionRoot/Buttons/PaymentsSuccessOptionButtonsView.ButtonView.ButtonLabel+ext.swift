//
//  PaymentsSuccessOptionButtonsView.ButtonView.ButtonLabel+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import SwiftUI

extension PaymentsSuccessOptionButtonsView.ButtonView.ButtonLabel {
    
    init(
        with option: Payments.ParameterSuccessOptionButtons.Option
    ) {
        self.init(title: option.title, icon: option.icon)
    }
}
