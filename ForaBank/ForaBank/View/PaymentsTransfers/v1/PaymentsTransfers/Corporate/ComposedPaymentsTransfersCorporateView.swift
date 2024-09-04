//
//  ComposedPaymentsTransfersCorporateView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.09.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct ComposedPaymentsTransfersCorporateView: View {
    
    let corporate: PaymentsTransfersCorporate
    
    var body: some View {
        
        Text("TBD " + String(describing: corporate))
            .frame(maxHeight: .infinity)
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Text("TBD: Profile without QR")
                }
            }
    }
}

extension ComposedPaymentsTransfersCorporateView {}
