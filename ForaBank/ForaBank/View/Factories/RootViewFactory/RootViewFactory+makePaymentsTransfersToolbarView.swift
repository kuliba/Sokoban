//
//  RootViewFactory+makePaymentsTransfersToolbar.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import SwiftUI

extension RootViewFactory {
    
    @ToolbarContentBuilder
    func makePaymentsTransfersToolbar(
        binder: PaymentsTransfersPersonalDomain.Binder
    ) -> some ToolbarContent {
        
        makeUserAccountToolbarButton {
            
            binder.flow.event(.select(.outside(.userAccount)))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            
            Button {
                
                binder.flow.event(.select(.outside(.scanQR)))
                
            } label: {
                
                Image(systemName: "qrcode")
            }
        }
    }
}
