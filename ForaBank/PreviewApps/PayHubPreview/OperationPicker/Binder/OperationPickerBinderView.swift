//
//  OperationPickerBinderView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

struct OperationPickerBinderView<ContentView>: View
where ContentView: View {
    
    @ObservedObject private var content: OperationPickerContent
    @ObservedObject private var flow: PayHubPickerFlow
    
    private let factory: Factory
    
    init(
        binder: OperationPickerBinder,
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

extension OperationPickerBinderView {
    
    typealias Factory = OperationPickerFlowStateWrapperViewFactory<ContentView>
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

#Preview {
    OperationPickerBinderView(
        binder: .preview,
        factory: .init(
            makeContent: { Text(String(describing: $0)) }
        )
    )
}

private extension OperationPickerBinder {
    
    static let preview: OperationPickerBinder = .init(
        content: .stub(loadResult: []),
        flow: .stub(),
        bind: { content, flow in content.$state.sink { _ in _ = flow }}
    )
}
