//
//  RootViewFactory+makeCorporateTransfers.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import PayHubUI
import SwiftUI

extension RootViewFactory {
    
    @ViewBuilder
    func makeCorporateTransfers(
        corporateTransfers: any CorporateTransfersProtocol
    ) -> some View {
        
        if let binder = corporateTransfers.corporateTransfersBinder {
            
            makeCorporateTransfers(binder: binder)
            
        } else {
            
            Text("Unexpected corporateTransfers type \(String(describing: corporateTransfers))")
                .foregroundColor(.red)
        }
    }
    
    @inlinable
    func makeCorporateTransfers(
        binder: CorporateTransfers
    ) -> some View {
        
        Text("TBD")
    }
}
