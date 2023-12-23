//
//  ButtonView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

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
                
                text(state.value, config: config.active.text)
            }
        }
        .frame(height: buttonHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func text(
        _ text: String,
        config: TextConfig
    ) -> some View {
        
        Text(text)
            .font(config.textFont)
            .foregroundColor(config.textColor)
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
