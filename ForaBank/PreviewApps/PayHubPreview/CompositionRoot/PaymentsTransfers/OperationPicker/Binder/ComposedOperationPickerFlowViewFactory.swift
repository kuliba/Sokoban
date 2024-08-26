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
}

extension ComposedOperationPickerFlowViewFactory {
    
    typealias MakeDestinationView = (OperationPickerFlowItem<Exchange, LatestFlow, Templates>) -> DestinationView
    typealias Item = OperationPickerState.Item
    typealias MakeItemLabel = (Item) -> ItemLabel
}
