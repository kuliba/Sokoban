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
        
        PaymentsTransfersCorporateContentView(content: corporate)
    }
}

extension ComposedPaymentsTransfersCorporateView {}
