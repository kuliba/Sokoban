//
//  ComposedOperationPickerFlowViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 26.08.2024.
//

struct ComposedOperationPickerFlowViewFactory<ItemLabel> {
    
    let makeItemLabel: MakeItemLabel
}

extension ComposedOperationPickerFlowViewFactory {
    
    typealias Item = OperationPickerState.Item
    typealias MakeItemLabel = (Item) -> ItemLabel
}
