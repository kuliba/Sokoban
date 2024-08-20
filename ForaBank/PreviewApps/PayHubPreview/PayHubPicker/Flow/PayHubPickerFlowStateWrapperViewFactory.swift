//
//  PayHubPickerFlowStateWrapperViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct PayHubPickerFlowStateWrapperViewFactory<ContentView> {
    
    let makeContent: MakeContent
}

extension PayHubPickerFlowStateWrapperViewFactory {
    
    typealias MakeContent = (PayHubPickerContent) -> ContentView
}
