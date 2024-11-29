//
//  ComposedOperationPickerFlowView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 24.08.2024.
//

import RxViewModel
import SwiftUI

public struct ComposedOperationPickerFlowView<DestinationView, ItemLabel, Exchange, Latest, LatestFlow, Status, Templates>: View
where DestinationView: View,
      ItemLabel: View,
      Latest: Equatable {
    
    private let binder: Binder
    private let factory: Factory
    
    public init(
        binder: Binder,
        factory: Factory
    ) {
        self.binder = binder
        self.factory = factory
    }
    
    public var body: some View {
        
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

public extension ComposedOperationPickerFlowView {
    
    typealias Domain = OperationPickerDomain<Exchange, Latest, LatestFlow, Status, Templates>
    typealias Binder = Domain.Binder
    typealias Factory = ComposedOperationPickerFlowViewFactory<DestinationView, ItemLabel, Exchange, Latest, LatestFlow, Status, Templates>
}

private extension ComposedOperationPickerFlowView {
    
    func makeContentView(
        _ content: OperationPickerContent<Latest>
    ) -> some View {
        
        RxWrapperView(
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
