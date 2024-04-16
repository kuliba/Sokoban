//
//  AnywayPaymentLayoutView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct AnywayPaymentLayoutView<ElementView, FooterView>: View
where ElementView: View,
      FooterView: View {
    
    let elements: [AnywayPayment.Element]
    let elementView: (AnywayPayment.Element) -> ElementView
    let footerView: () -> FooterView
    
    var body: some View {
        
        VStack {
            
            ScrollView {
                
                VStack(spacing: 24) {
                    
                    ForEach(elements, content: elementView)
                        .padding(.horizontal)
                }
            }
            
            footerView()
        }
    }
}

struct AnywayPaymentLayoutView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentLayoutView(
            elements: .preview,
            elementView: { Text(String(describing: $0).prefix(80)) },
            footerView: { Text("Footer") }
        )
    }
}
