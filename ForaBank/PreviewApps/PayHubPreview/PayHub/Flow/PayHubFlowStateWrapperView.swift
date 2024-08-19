//
//  PayHubFlowStateWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

struct PayHubFlowStateWrapperView<ContentView>: View
where ContentView: View {
    
    @StateObject private var content: PayHubContent
    @StateObject private var flow: PayHubFlow
    
    private let factory: Factory
    
    init(
        binder: PayHubBinder,
        factory: Factory
    ) {
        self._content = .init(wrappedValue: binder.content)
        self._flow = .init(wrappedValue: binder.flow)
        self.factory = factory
    }
    
    var body: some View {
        
        factory.makeContent(content)
            .onFirstAppear { content.event(.load) }
            .navigationDestination(
                destination: flow.state.selected,
                dismiss: { content.event(.select(nil)) },
                content: { Text("TBD: destination " + String(describing: $0)) }
            )
    }
}

extension PayHubFlowStateWrapperView {
    
    typealias Factory = PayHubViewFactory<ContentView>
}

extension PayHubFlowItem: Identifiable {
    
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

#Preview {
    PayHubFlowStateWrapperView(
        binder: .preview,
        factory: .init(
            makeContent: { Text(String(describing: $0)) }
        )
    )
}

private extension PayHubBinder {
    
    static let preview: PayHubBinder = .init(
        content: .stub(loadResult: .success([])),
        flow: .stub()
    )
}
