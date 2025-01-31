//
//  RootViewFactory+transportPaymentsView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import SwiftUI

extension RootViewFactory {
    
    @ViewBuilder
    func transportPaymentsView(
        _ transport: TransportPaymentsViewModel
    ) -> some View {
        
        components.makeTransportPaymentsView(transport)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
    }
}
