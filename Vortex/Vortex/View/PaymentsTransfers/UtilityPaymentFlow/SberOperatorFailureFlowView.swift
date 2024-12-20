//
//  SberOperatorFailureFlowView.swift
//
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct SberOperatorFailureFlowView<Operator, ContentView, DestinationView>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let contentView: () -> ContentView
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        contentView()
            .navigationDestination(
                destination: state.destination,
                dismissDestination: { event(()) },
                content: destinationView
            )
    }
}

extension SberOperatorFailureFlowView {
    
    typealias Destination = State.Destination
    
    typealias State = SberOperatorFailureFlowState<Operator>
    typealias Event = ()
}

extension SberOperatorFailureFlowState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payByInstructions: return .payByInstructions
        }
    }
    
    enum ID: Hashable {
        
        case payByInstructions
    }
}
