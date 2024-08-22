//
//  OperationPickerFlowStateWrapperViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct OperationPickerFlowStateWrapperViewFactory<ContentView> {
    
    let makeContent: MakeContent
}

extension OperationPickerFlowStateWrapperViewFactory {
    
    typealias MakeContent = (OperationPickerContent) -> ContentView
}
