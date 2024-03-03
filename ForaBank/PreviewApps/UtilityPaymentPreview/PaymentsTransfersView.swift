//
//  PaymentsTransfersView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI

struct PaymentsTransfersView: View {
    
    @ObservedObject var viewModel: PaymentsTransfersViewModel
    
    var body: some View {
        
        ZStack {
            
            Button("Utility Payment") { viewModel.event(.openPrePayment) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if viewModel.state.status == .inflight {
                
                ZStack {
                    
                    Color.black.opacity(0.3)
                    
                    ProgressView()
                }
                .ignoresSafeArea()
            }
        }
    }
}

struct PaymentsTransfersView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsTransfersView(viewModel: .default())
    }
}
