//
//  ButtonView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct ButtonView: View {
    
    let button: SberQRConfirmPaymentState.Button
    let pay: () -> Void
    
    let config: ButtonConfig
    
    private let buttonHeight: CGFloat = 56
    
    var body: some View {
        
        ZStack {
            
            config.backgroundColor
            
            Button(action: pay) {
                
                text(button.value, config: config.text)
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
        
        ButtonView(button: .preview, pay: {}, config: .default)
    }
}
