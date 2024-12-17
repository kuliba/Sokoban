//
//  PaymentComponents.ButtonView+goToMain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import PaymentComponents
import SwiftUI

extension PaymentComponents.ButtonView {
    
    static func goToMain(
        title: String = "На главный",
        color: PaymentComponents.Button.Color = .red,
        goToMain: @escaping () -> Void
    ) -> Self {
        
        self.init(
            state: .init(
                id: .buttonPay,
                value: title,
                color: color,
                action: .pay,
                placement: .bottom
            ),
            event: goToMain,
            config: .iForaMain
        )
    }
}
