//
//  ComposedOperationPickerFlowView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 24.08.2024.
//

import RxViewModel
import PayHubUI
import SwiftUI

struct ComposedOperationPickerFlowView<DestinationView, ItemLabel>: View
where DestinationView: View,
      ItemLabel: View {
    
    let binder: Binder
    let factory: Factory
    
    var body: some View {
        
        RxWrapperView(
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
    
    typealias Domain = OperationPickerDomain
    typealias Binder = Domain.Binder
    typealias Factory = ComposedOperationPickerFlowViewFactory<DestinationView, ItemLabel>
}

private extension ComposedOperationPickerFlowView {
    
    func makeContentView(
        _ content: OperationPickerContent
    ) -> some View {
        
        RxWrapperView(
            model: content,
            makeContentView: { state, event in
                
                OperationPickerContentView(
                    state: state,
                    event: event,
                    config: .primary,
                    itemLabel: factory.makeItemLabel
                )
            }
        )
        .onFirstAppear { content.event(.load) }
    }
}
