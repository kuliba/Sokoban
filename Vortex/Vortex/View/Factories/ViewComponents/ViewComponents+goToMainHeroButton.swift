//
//  ViewComponents+goToMainHeroButton.swift
//  Vortex
//
//  Created by Igor Malyarov on 26.03.2025.
//

import PaymentComponents
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func goToMainHeroButton(
    ) -> some View {
        
        PaymentComponents.ButtonView.goToMain(goToMain: goToMain)
            .conditionalBottomPadding()
    }
}
