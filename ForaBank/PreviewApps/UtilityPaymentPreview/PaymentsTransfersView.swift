//
//  PaymentsTransfersView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI
import UIPrimitives

struct PaymentsTransfersView: View {
    
    @ObservedObject var viewModel: PaymentsTransfersViewModel
    
    @State private var item: Item?
    
    let factory: PaymentsTransfersViewFactory
    
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
        .navigationDestination(
            item: $item,
            content: destinationView
        )
    }
    
    private func destinationView(
        item: Item
    ) -> some View {
        // switch???
        
        factory.prePaymentView()
    }
}

struct Item: Identifiable {
    let id: String
}

struct PaymentsTransfersView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsTransfersView(
            viewModel: .default(),
            factory: .init()
        )
    }
}
