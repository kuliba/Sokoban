//
//  RootViewFactory+makeCorporateTransfersView.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import PayHubUI
import RxViewModel
import SwiftUI

extension RootViewFactory {
    
    @ViewBuilder
    func makeCorporateTransfersView(
        _ corporateTransfers: any CorporateTransfersProtocol
    ) -> some View {
        
        if let corporateTransfers = corporateTransfers.corporateTransfers {
            
            makeCorporateTransfersView(corporateTransfers)
            
        } else {
            
            Text("Unexpected corporateTransfers type \(String(describing: corporateTransfers))")
                .foregroundColor(.red)
        }
    }
    
    @inlinable
    func makeCorporateTransfersView(
        _ corporateTransfers: PaymentsTransfersCorporateTransfers
    ) -> some View {
        
        HStack {
            
            PTSectionTransfersView.TransfersButtonView(viewModel: .init(
                type: .betweenSelf,
                action: { corporateTransfers.meToMe.event(.select(.meToMe)) }
            ))
            .background(makeMeToMeFlowView(corporateTransfers.meToMe))
            
            Button("Open product") {
                
                corporateTransfers.openProduct.event(.select(.openProduct))
            }
            .background(makeOpenProductFlowView(corporateTransfers.openProduct))
            
            Spacer()
        }
        .padding(.top, 16)
    }
}
