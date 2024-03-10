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
#warning("remodel spinner and NavigationView position to resemble app")
            
            NavigationView {
                
                utilityPaymentButton()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            spinner()
        }
    }
    
    private func utilityPaymentButton() -> some View {
        
        Button(
            "Utility Payment",
            action: { viewModel.event(.openUtilityPayment) }
        )
        .navigationDestination(
            item: .init(
                get: { viewModel.state.navigationState },
                set: { if $0 == nil { viewModel.event(.utilityPayment(.prePayment(.back))) }}
            ),
            content: destinationView
        )
    }
    
    @ViewBuilder
    private func destinationView(
        navigationState: PaymentsTransfersState.NavigationState
    ) -> some View {
        
        switch navigationState {
        case let .prePaymentOptions(prePaymentOptions):
            switch prePaymentOptions {
            case .failure:
                Text("TBD: prePaymentOptionsFailureView")
//                factory.prePaymentFailureView { viewModel.event(.utilityPayment(.prePayment(.payByInstruction))) }
                
            case .success:
                Text("TBD: prePaymentOptionsView")
                // factory.prePaymentView { _ in fatalError() }
                    .navigationDestination(
                        item: .init(
                            get: {
                                let state = viewModel.state.prePaymentNavigationState
                                print(state ?? "nil")
                                return state
                            },
                            set: { if $0 == nil { viewModel.event(.utilityPayment(.prePayment(.back))) }}
                        ),
                        content: prePaymentDestinationView
                    )
            }
            
        case let .prePayment(prePayment):
            switch prePayment {
            case .failure:
                Text("TBD: prePaymentFailureView")
//                factory.prePaymentFailureView { viewModel.event(.utilityPayment(.prePayment(.payByInstruction))) }
                
            case .success:
                Text("TBD: prePaymentView")
//                factory.prePaymentView { _ in fatalError() }
//                    .navigationDestination(
//                        item: .init(
//                            get: {
//                                let state = viewModel.state.prePaymentNavigationState
//                                print(state ?? "nil")
//                                return state
//                            },
//                            set: { if $0 == nil { viewModel.event(.prePayment(.back)) }}
//                        ),
//                        content: prePaymentDestinationView
//                    )
            }
        }
    }
    
    private func prePaymentDestinationView(
        prePaymentNavigationState: PaymentsTransfersState.PrePaymentNavigationState
    ) -> some View {
        
        Text("Utility Payment View")
    }
    
    private func spinner() -> some View {
        
        ZStack {
            
            Color.black.opacity(0.5)
            
            ProgressView()
        }
        .ignoresSafeArea()
        .opacity(viewModel.state.status == .inflight ? 1 : 0)
    }
}

struct PaymentsTransfersView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsTransfersView(
            viewModel: .default(),
            factory: .init()
        )
    }
}
