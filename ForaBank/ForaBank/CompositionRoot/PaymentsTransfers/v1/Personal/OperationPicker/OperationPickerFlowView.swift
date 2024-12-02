//
//  OperationPickerFlowView.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import SwiftUI

struct OperationPickerFlowView<ContentView, DestinationView>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
    
    var body: some View {
        
        factory.makeContent()
            .navigationDestination(
                destination: state.navigation?.destination,
                dismiss: { event(.dismiss) },
                content: factory.makeDestination
            )
    }
}

extension OperationPickerFlowView {
    
    typealias Domain = OperationPickerDomain
    typealias FlowDomain = Domain.FlowDomain
    
    typealias State = FlowDomain.State
    typealias Event = FlowDomain.Event
    typealias Factory = OperationPickerFlowViewFactory<ContentView, DestinationView>
}

// MARK: - UI Mapping

extension OperationPickerDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
            
        case let .exchange(exchange):
            return .exchange(exchange)
        
        case let .latest(latest):
            return .latest(latest)
        
        case let .status(status):
            return .status(status)
        
        case .templates:
            return nil
        }
    }
    
    enum Destination {
        
        case exchange(CurrencyWalletViewModel)
        case latest(LatestFlowStub)
        case status(OperationPickerFlowStatus)
    }
}

extension OperationPickerDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .exchange(exchange):
            return .exchange(.init(exchange))
            
        case let .latest(latest):
            return .latest(.init(latest))
            
        case let .status(status):
            return .status(status)
        }
    }
    
    enum ID: Hashable {
        
        case exchange(ObjectIdentifier)
        case latest(ObjectIdentifier)
        case status(OperationPickerFlowStatus)
    }
}
