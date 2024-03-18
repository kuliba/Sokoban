//
//  PaymentsTransfersView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI
import UIPrimitives

struct PaymentsTransfersView: View {
    
    @StateObject var viewModel: PaymentsTransfersViewModel
    
    let factory: PaymentsTransfersViewFactory
    
    var body: some View {
        
        utilityPaymentButton()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension PaymentsTransfersView {
    
    func utilityPaymentButton() -> some View {
        
        Button(
            "Utility Payment",
            action: { viewModel.event(.flow(.utilityFlow(.initiate))) }
        )
        .navigationDestination(
            item: .init(
                get: { viewModel.state.navigationState },
                set: { if $0 == nil { viewModel.event(.flow(.back)) }}
            ),
            content: destinationView
        )
    }
    
    @ViewBuilder
    func destinationView(
        navigationState: PaymentsTransfersState.NavigationState
    ) -> some View {
        
        switch navigationState {
        case .payingByInstruction:
            Text("TBD: pay by Instruction here")
            
        case let .prePaymentOptions(prePaymentOptions):
            switch prePaymentOptions {
            case .failure:
                factory.prePaymentFailureView {
                    
                    // viewModel.event(.utilityFlow(.prePayment(.payByInstruction)))
                    fatalError()
                }
                
            case .success:
                Text("TBD: prePaymentOptionsView")
                // factory.prePaymentView { _ in fatalError() }
                //                    .navigationDestination(
                //                        item: .init(
                //                            get: {
                //                                let state = viewModel.state.prePaymentNavigationState
                //                                print(state ?? "nil")
                //                                return state
                //                            },
                //                            set: { if $0 == nil { viewModel.event(.utilityPayment(.prePayment(.back))) }}
                //                        ),
                //                        content: prePaymentDestinationView
                //                    )
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
            
        case .scanning:
            Text("TBD: scanning")
            
        case .other:
            Text("Just other destination")
        }
    }
    
    func prePaymentDestinationView(
        prePaymentNavigationState: PaymentsTransfersState.PrePaymentNavigationState
    ) -> some View {
        
        Text("Utility Payment View")
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
