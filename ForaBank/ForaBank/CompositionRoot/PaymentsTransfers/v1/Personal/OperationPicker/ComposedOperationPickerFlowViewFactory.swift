//
//  ComposedOperationPickerFlowViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub

struct ComposedOperationPickerFlowViewFactory<DestinationView, ItemLabel> {
    
    let makeDestinationView: MakeDestinationView
    let makeItemLabel: MakeItemLabel
    
    init(
        makeDestinationView: @escaping MakeDestinationView,
        makeItemLabel: @escaping MakeItemLabel
    ) {
        self.makeDestinationView = makeDestinationView
        self.makeItemLabel = makeItemLabel
    }
}

extension ComposedOperationPickerFlowViewFactory {
    
    typealias MakeDestinationView = (OperationPickerDomain.Navigation.Destination) -> DestinationView
    typealias Item = OperationPickerState.Item
    typealias MakeItemLabel = (Item) -> ItemLabel
}
