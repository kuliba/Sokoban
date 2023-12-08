//
//  ButtonView.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct ButtonView: View {
    
    let button: SberQRConfirmPaymentState.Button
    
    var body: some View {
        Text("ButtonView")
    }
}

// MARK: - Previews

struct ButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ButtonView(button: .preview)
    }
}
