//
//  ButtonView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import PrimitiveComponents
import SwiftUI

struct ButtonView: View {
    
    let state: SberQRConfirmPaymentState.FixedAmount.Button
    let event: () -> Void
    let config: ButtonConfig
    
    private let buttonHeight: CGFloat = 56
    
    var body: some View {
        
        ZStack {
            
            config.active.backgroundColor
            
            Button(action: event) {
                
                state.value.text(withConfig: config.active.text)
            }
        }
        .frame(height: buttonHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Previews

struct ButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
    
        buttonView(.preview)
    }
    
    private static func buttonView(
        _ button: SberQRConfirmPaymentState.FixedAmount.Button
    ) -> some View {
        
        ButtonView(state: .preview, event: {}, config: .default)
    }
}
