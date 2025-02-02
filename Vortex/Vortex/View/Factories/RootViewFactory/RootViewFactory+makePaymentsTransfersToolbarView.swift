//
//  RootViewFactory+makePaymentsTransfersToolbar.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import SwiftUI

extension ViewComponents {
    
    @ToolbarContentBuilder
    func makePaymentsTransfersToolbar(
        binder: PaymentsTransfersPersonalDomain.Binder
    ) -> some ToolbarContent {
        
        makeUserAccountToolbarButton {
            
            binder.flow.event(.select(.userAccount))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            
            Button {
                
                binder.flow.event(.select(.scanQR))
                
            } label: {
                
                Image.ic24BarcodeScanner2
            }
        }
    }
}
