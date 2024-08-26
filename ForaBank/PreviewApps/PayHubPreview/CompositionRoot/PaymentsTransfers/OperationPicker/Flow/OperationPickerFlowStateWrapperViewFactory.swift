//
//  OperationPickerFlowStateWrapperViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI
import PayHub

struct OperationPickerFlowStateWrapperViewFactory<ContentView, DestinationView> {
    
    let makeContent: MakeContent
    let makeDestination: MakeDestination
}

extension OperationPickerFlowStateWrapperViewFactory {
    
    typealias MakeContent = (OperationPickerContent) -> ContentView
    typealias MakeDestination = (OperationPickerFlowItem<Exchange, LatestFlow, Templates>) -> DestinationView
}
