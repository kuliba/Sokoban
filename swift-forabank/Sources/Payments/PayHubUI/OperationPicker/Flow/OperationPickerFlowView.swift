//
//  OperationPickerFlowView.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import SwiftUI

public struct OperationPickerFlowView<ContentView, DestinationView, Exchange, Latest, LatestFlow, Status, Templates>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
    
    public var body: some View {
        
        factory.makeContent()
            .navigationDestination(
                destination: state.selected,
                dismiss: { event(.select(nil)) },
                content: factory.makeDestination
            )
    }
}

public extension OperationPickerFlowView {
    
    typealias State = OperationPickerFlowState<Exchange, LatestFlow, Status, Templates>
    typealias Event = OperationPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
    typealias Factory = OperationPickerFlowViewFactory<ContentView, DestinationView, Exchange, LatestFlow, Templates>
}

extension OperationPickerFlowItem: Identifiable {
    
    public var id: ID {
        switch self {
        case .exchange:  return .exchange
        case .latest:    return .latest
        case .templates: return .templates
        }
    }
    
    public enum ID: Hashable {
        
        case exchange, latest, templates
    }
}
