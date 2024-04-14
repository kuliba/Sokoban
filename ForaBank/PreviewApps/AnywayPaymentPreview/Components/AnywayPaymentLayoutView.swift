//
//  AnywayPaymentLayoutView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct AnywayPaymentLayoutView<ElementView>: View
where ElementView: View {
    
    let elements: [AnywayPayment.Element]
    let elementView: (AnywayPayment.Element) -> ElementView
    
    var body: some View {
        
        ScrollView {
            
            ForEach(elements, content: elementView)
                .padding(.horizontal)
        }
    }
}

struct AnywayPaymentLayoutView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentLayoutView(
            elements: .preview,
            elementView: { Text(String(describing: $0)) }
        )
    }
}
