//
//  AnywayPaymentElementFieldView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct AnywayPaymentElementFieldView: View {
    
    let state: AnywayPayment.AnywayElement.UIComponent.Field
    
    var body: some View {
        
        Text(String(describing: state))
            .font(.body.italic())
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AnywayPaymentElementFieldView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentElementFieldView(state: .preview)
    }
}
