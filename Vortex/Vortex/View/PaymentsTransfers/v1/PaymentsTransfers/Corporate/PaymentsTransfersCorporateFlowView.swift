//
//  PaymentsTransfersCorporateFlowView.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.11.2024.
//

import SwiftUI

struct PaymentsTransfersCorporateFlowView<ContentView, DestinationView, FullScreenCoverView>: View
where ContentView: View,
      DestinationView: View,
      FullScreenCoverView: View {

    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        factory.makeContentView()
            .fullScreenCover(
                cover: state.fullScreenCover,
                content: factory.makeFullScreenCoverView
            )
            .navigationDestination(
                destination: state.destination,
                content: factory.makeDestinationView
            )
    }
}

extension PaymentsTransfersCorporateFlowView {
    
    typealias State = PaymentsTransfersCorporateDomain.FlowDomain.State
    typealias Event = PaymentsTransfersCorporateDomain.FlowDomain.Event
    typealias Factory = PaymentsTransfersCorporateFlowViewFactory<ContentView, DestinationView, FullScreenCoverView>
}

// MARK: - UI mapping

private extension PaymentsTransfersCorporateDomain.FlowDomain.State {
    
    var destination: PaymentsTransfersCorporateNavigation.Destination? {
        
        switch navigation {
        case .none, .main, .userAccount:
            return .none
        }
    }
    
    var fullScreenCover: PaymentsTransfersCorporateNavigation.FullScreenCover? {
        
        switch navigation {
        case .none, .main, .userAccount:
            return .none
        }
    }
}

extension PaymentsTransfersCorporateNavigation {
    
    enum Destination {
        
    }
    
    enum FullScreenCover {
        
    }
}

extension PaymentsTransfersCorporateNavigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
            
        }
    }
    
    enum ID: Hashable {
        
    }
}

extension PaymentsTransfersCorporateNavigation.FullScreenCover: Identifiable {
    
    var id: ID {
        
        switch self {
            
        }
    }
    
    enum ID: Hashable {
        
    }
}
