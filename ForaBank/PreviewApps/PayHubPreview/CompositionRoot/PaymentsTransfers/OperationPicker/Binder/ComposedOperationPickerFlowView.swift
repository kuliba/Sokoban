//
//  ComposedOperationPickerFlowView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 24.08.2024.
//

import PayHubUI
import SwiftUI

struct ComposedOperationPickerFlowView<ItemLabel>: View
where ItemLabel: View {
    
    let binder: OperationPickerBinder
    let itemLabel: (Item) -> ItemLabel
    
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
                        makeDestination: {
                            
                            Text("TBD: destination " + String(describing: $0))
                        }
                    )
                )
            }
        )
    }
}

extension ComposedOperationPickerFlowView {

    typealias Item = OperationPickerState.Item
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
                    itemLabel: itemLabel
                )
            }
        )
        .onFirstAppear { content.event(.load) }
    }
}
