//
//  OperatorFailureFlowView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct OperatorFailureFlowView<Content: View, DestinationView: View>: View
where Content: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let content: () -> Content
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
    
    typealias State = UtilityPaymentFlowState.Destination.OperatorFailure
    typealias Event = ()
}

//#Preview {
//    OperatorFailureView()
//}
