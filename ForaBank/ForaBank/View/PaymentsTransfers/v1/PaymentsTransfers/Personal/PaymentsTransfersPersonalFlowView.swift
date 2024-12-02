//
//  PaymentsTransfersPersonalFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.11.2024.
//

import SwiftUI

struct PaymentsTransfersPersonalFlowView<ContentView, DestinationView, FullScreenCoverView>: View
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

extension PaymentsTransfersPersonalFlowView {
    
    typealias State = PaymentsTransfersPersonalDomain.FlowDomain.State
    typealias Event = PaymentsTransfersPersonalDomain.FlowDomain.Event
    typealias Factory = PaymentsTransfersPersonalFlowViewFactory<ContentView, DestinationView, FullScreenCoverView>
}

// MARK: - UI mapping

private extension PaymentsTransfersPersonalDomain.FlowDomain.State {
    
    var destination: PaymentsTransfersPersonalNavigation.Destination? {
        
        switch navigation {
        case .none, .templates, .userAccount:
            return .none
        }
    }
    
    var fullScreenCover: PaymentsTransfersPersonalNavigation.FullScreenCover? {
        
        switch navigation {
        case .none, .templates, .userAccount:
            return .none
        }
    }
}

extension PaymentsTransfersPersonalNavigation {
    
    enum Destination {
        
    }
    
    enum FullScreenCover {
        
    }
}

extension PaymentsTransfersPersonalNavigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
            
        }
    }
    
    enum ID: Hashable {
        
    }
}

extension PaymentsTransfersPersonalNavigation.FullScreenCover: Identifiable {
    
    var id: ID {
        
        switch self {
            
        }
    }
    
    enum ID: Hashable {
        
    }
}
