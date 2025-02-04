//
//  RootViewFactory+transportPaymentsView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import SwiftUI

extension ViewComponents {
    
    @ViewBuilder
    func transportPaymentsView(
        _ transport: TransportPaymentsViewModel
    ) -> some View {
        
        makeTransportPaymentsView(transport)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
    }
}
