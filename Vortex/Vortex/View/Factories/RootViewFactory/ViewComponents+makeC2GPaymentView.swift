//
//  ViewComponents+makeC2GPaymentView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentView(
        _ binder: C2GPaymentDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        VStack(spacing: 16) {
            
            Text("TBD: C2G Payment")
                .font(.headline)
            
            Button("connectivityFailure") {
                
                binder.flow.event(.select(.pay("connectivityFailure")))
            }
            
            Button("serverFailure") {
                
                binder.flow.event(.select(.pay("serverFailure")))
            }
            
            Button("success") {
                
                binder.flow.event(.select(.pay(UUID().uuidString)))
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .buttonBorderShape(.roundedRectangle)
        .buttonStyle(.bordered)
        .navigationBarWithBack(title: "Оплата", dismiss: dismiss)
    }
}
