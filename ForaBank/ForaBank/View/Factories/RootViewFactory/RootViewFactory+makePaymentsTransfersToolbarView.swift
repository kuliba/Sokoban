//
//  RootViewFactory+makePaymentsTransfersToolbarView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import SwiftUI

extension RootViewFactory {
    
    @ViewBuilder
    func makePaymentsTransfersToolbarView(
        toolbar: PayHubUI.PaymentsTransfersPersonalToolbar
    ) -> some View {
        
        if let binder = toolbar.toolbarBinder {
            
            makePaymentsTransfersToolbarView(binder: binder)
            
        } else {
            
            Text("Unexpected toolbar type \(String(describing: toolbar))")
                .foregroundColor(.red)
        }
    }
    
    private func makePaymentsTransfersToolbarView(
        binder: PaymentsTransfersPersonalToolbarDomain.Binder
    ) -> some View {
        
        ComposedPaymentsTransfersPersonalToolbarView(
            binder: binder,
            factory: .init(
                makeDestinationView: {
                    
                    switch $0 {
                    case let .profile(profileModel):
                        Text(String(describing: profileModel))
                    }
                },
                makeFullScreenView: {
                    
                    switch $0 {
                    case let .qr(qrModel):
                        VStack(spacing: 32) {
                            
                            Text(String(describing: qrModel))
                        }
                    }
                },
                makeProfileLabel: {
                    
                    HStack {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                },
                makeQRLabel: {
                    
                    Image(systemName: "qrcode")
                }
            )
        )
    }
}
