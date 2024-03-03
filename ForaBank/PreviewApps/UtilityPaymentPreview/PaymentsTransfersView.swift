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
    
    let factory: PaymentsTransfersViewFactory
    
    var body: some View {
        
        ZStack {
            
            Button("Utility Payment") { viewModel.event(.openPrePayment) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if viewModel.state.status == .inflight {
                
                ZStack {
                    
                    Color.black.opacity(0.5)
                    
                    ProgressView()
                }
                .ignoresSafeArea()
            }
        }
        .navigationDestination(
            item: .init(
                get: { viewModel.state.navigationState },
                set: { if $0 == nil { viewModel.event(.resetDestination) }}
            ),
            content: destinationView
        )
    }
    
    @ViewBuilder
    private func destinationView(
        navigationState: PaymentsTransfersState.NavigationState
    ) -> some View {
        
        switch navigationState {
        case let .prePayment(prePayment):
            switch prePayment {
            case .failure:
                factory.prePaymentFailureView { viewModel.event(.payByInstruction) }
            
            case .success:
                factory.prePaymentView { viewModel.event(.prePayment($0)) }
            }
        }
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
