//
//  AnywayPaymentElementFieldView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct AnywayPaymentElementFieldView: View {
    
    let state: AnywayPayment.UIComponent.Field
    
    var body: some View {
        
        Text(String(describing: state))
    }
}

struct AnywayPaymentElementFieldView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentElementFieldView(state: .preview)
    }
}
