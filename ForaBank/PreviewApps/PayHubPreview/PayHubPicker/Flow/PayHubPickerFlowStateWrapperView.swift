//
//  PayHubPickerFlowStateWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

struct PayHubPickerFlowStateWrapperView<ContentView>: View
where ContentView: View {
    
    @StateObject private var content: PayHubPickerContent
    @StateObject private var flow: PayHubPickerFlow
    
    private let factory: Factory
    
    init(
        binder: PayHubPickerBinder,
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

extension PayHubPickerFlowStateWrapperView {
    
    typealias Factory = PayHubPickerFlowStateWrapperViewFactory<ContentView>
}

extension PayHubPickerFlowItem: Identifiable {
    
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
    PayHubPickerFlowStateWrapperView(
        binder: .preview,
        factory: .init(
            makeContent: { Text(String(describing: $0)) }
        )
    )
}

private extension PayHubPickerBinder {
    
    static let preview: PayHubPickerBinder = .init(
        content: .stub(loadResult: []),
        flow: .stub()
    )
}
