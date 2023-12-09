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
    
    var body: some View {
        
        Button(button.value, action: pay)
            .font(.headline.bold())
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.red)
            )
    }
}

// MARK: - Previews

struct ButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ButtonView(button: .preview, pay: {})
    }
}
