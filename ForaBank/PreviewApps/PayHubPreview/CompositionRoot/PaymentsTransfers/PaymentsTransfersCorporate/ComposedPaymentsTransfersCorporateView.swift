//
//  ComposedPaymentsTransfersCorporateView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.09.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct ComposedPaymentsTransfersCorporateView<ContentView>: View
where ContentView: View {
    
    let corporate: Corporate
    let makeContentView: () -> ContentView
    
    var body: some View {
        
        makeContentView()
    }
}

extension ComposedPaymentsTransfersCorporateView {
    
    typealias Corporate = PaymentsTransfersCorporate
}
