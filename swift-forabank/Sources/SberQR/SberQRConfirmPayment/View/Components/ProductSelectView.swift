//
//  ProductSelectView.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct ProductSelectView: View {
    
    typealias Event = SberQRConfirmPaymentEvent.ProductSelectEvent
    
    let state: ProductSelect
    let event: (Event) -> Void
    
    var body: some View {
        
        Text("ProductSelect")
            .onTapGesture {
                event(.toggleProductSelect)
            }
    }
}
