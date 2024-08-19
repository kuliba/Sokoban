//
//  TabViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct TabViewFactory<FlowView: View> {
    
    let makeFlowView: MakeFlowView
}

extension TabViewFactory {
    
    typealias MakeFlowView = (TabState.FlowModel) -> FlowView
}
