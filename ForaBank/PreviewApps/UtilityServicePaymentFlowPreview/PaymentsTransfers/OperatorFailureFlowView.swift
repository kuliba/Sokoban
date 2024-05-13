//
//  OperatorFailureFlowView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct OperatorFailureFlowView<ContentView, DestinationView>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let content: () -> ContentView
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        content()
            .navigationDestination(
                destination: state.destination,
                dismissDestination: { event(()) },
                content: destinationView
            )
    }
}

extension OperatorFailureFlowView {
    
    typealias Destination = State.Destination
    
    typealias UtilityFlowState = UtilityPaymentFlowState<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    typealias State = UtilityFlowState.Destination.OperatorFailureFlowState
    typealias Event = ()
}

//#Preview {
//    OperatorFailureView()
//}

extension UtilityPaymentFlowState.Destination.OperatorFailureFlowState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payByInstructions: return .payByInstructions
        }
    }
    
    enum ID: Hashable {
        
        case payByInstructions
    }
}
