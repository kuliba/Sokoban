//
//  ComposedOperationPickerFlowView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 24.08.2024.
//

import PayHubUI
import SwiftUI

struct ComposedOperationPickerFlowView<DestinationView, ItemLabel>: View
where DestinationView: View,
      ItemLabel: View {
    
    let binder: OperationPickerBinder
    let factory: Factory
    
    var body: some View {
        
        OperationPickerFlowWrapperView(
            model: binder.flow,
            makeContentView: {
                
                OperationPickerFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContent: {
                            
                            makeContentView(binder.content)
                        },
                        makeDestination: factory.makeDestinationView
                    )
                )
            }
        )
    }
}

extension ComposedOperationPickerFlowView {
    
    typealias Factory = ComposedOperationPickerFlowViewFactory<DestinationView, ItemLabel>
}

private extension ComposedOperationPickerFlowView {
    
    func makeContentView(
        _ content: OperationPickerContent
    ) -> some View {
        
        OperationPickerContentWrapperView(
            model: content,
            makeContentView: { state, event in
                
                OperationPickerContentView(
                    state: state,
                    event: event,
                    config: .preview,
                    itemLabel: factory.makeItemLabel
                )
            }
        )
        .onFirstAppear { content.event(.load) }
    }
}
