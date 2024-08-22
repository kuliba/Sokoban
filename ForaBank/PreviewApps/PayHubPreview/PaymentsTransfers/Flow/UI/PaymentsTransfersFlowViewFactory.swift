//
//  PaymentsTransfersFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import PayHubUI
import SwiftUI

struct PaymentsTransfersFlowViewFactory<Content, DestinationContent, FullScreenContent, Toolbar>
where Content: View,
      DestinationContent: View,
      Toolbar: ToolbarContent {
    
    @ViewBuilder let makeContent: MakeContent
    @ViewBuilder let makeDestinationContent: MakeDestinationContent
    @ViewBuilder let makeFullScreenContent: MakeFullScreenContent
    @ToolbarContentBuilder let makeToolbar: MakeToolbar
}

extension PaymentsTransfersFlowViewFactory {
    
    typealias MakeContent = () -> Content
    typealias Navigation = PaymentsTransfersFlowState.Navigation
    typealias MakeDestinationContent = (Navigation.Destination) -> DestinationContent
    typealias MakeFullScreenContent = (Navigation.FullScreen) -> FullScreenContent
    typealias MakeToolbar = (@escaping (PaymentsTransfersFlowEvent.Open) -> Void) -> Toolbar
}
