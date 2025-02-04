//
//  RootViewFactory+makeCorporateTransfersView.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import PayHubUI
import RxViewModel
import SwiftUI

extension ViewComponents {
    
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
        
        HStack(alignment: .top) {
            
            meToMeButton(corporateTransfers.meToMe)
            
            openProductButton(corporateTransfers.openProduct)
                .frame(height: 124)
        }
        .padding(.top, 16)
    }
    
    @inlinable
    func meToMeButton(
        _ meToMe: MeToMeDomain.Flow
    ) -> some View {
        
        PTSectionTransfersView.TransfersButtonView(viewModel: .init(
            type: .betweenSelf,
            action: { meToMe.event(.select(.meToMe)) }
        ))
        .background(makeMeToMeFlowView(meToMe))
    }
    
    @inlinable
    func openProductButton(
        _ openProduct: OpenProductDomain.Flow
    ) -> some View {
        
        Button {
            
            openProduct.event(.select(.openProduct))
        } label: {
            
            NewProductButtonLabel(
                icon: .ic24NewCardColor,
                title: "Открыть продукт",
                subTitle: "Чтобы открыть все возможности приложения",
                lineLimit: nil
            )
        }
        .background(makeOpenProductFlowView(openProduct))
    }
}
