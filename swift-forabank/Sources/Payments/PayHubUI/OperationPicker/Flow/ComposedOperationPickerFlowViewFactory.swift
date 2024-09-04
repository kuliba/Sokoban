//
//  ComposedOperationPickerFlowViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub

public struct ComposedOperationPickerFlowViewFactory<DestinationView, ItemLabel, Exchange, Latest, LatestFlow, Templates> {
    
    public let makeDestinationView: MakeDestinationView
    public let makeItemLabel: MakeItemLabel
    
    public init(
        makeDestinationView: @escaping MakeDestinationView,
        makeItemLabel: @escaping MakeItemLabel
    ) {
        self.makeDestinationView = makeDestinationView
        self.makeItemLabel = makeItemLabel
    }
}

public extension ComposedOperationPickerFlowViewFactory {
    
    typealias MakeDestinationView = (OperationPickerFlowItem<Exchange, LatestFlow, Templates>) -> DestinationView
    typealias Item = OperationPickerState<Latest>.Item
    typealias MakeItemLabel = (Item) -> ItemLabel
}
