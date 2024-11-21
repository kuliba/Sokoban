//
//  PaymentsTransfersPersonalFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.11.2024.
//

import SwiftUI

struct PaymentsTransfersPersonalFlowViewFactory<ContentView, DestinationView, FullScreenCoverView> {
    
    let makeContentView: MakeContentView
    let makeFullScreenCoverView: MakeFullScreenCoverView
    let makeDestinationView: MakeDestinationView
}

extension PaymentsTransfersPersonalFlowViewFactory {
    
   typealias MakeContentView = () -> ContentView
   typealias MakeFullScreenCoverView = (PaymentsTransfersPersonalNavigation.FullScreenCover) -> FullScreenCoverView
   typealias MakeDestinationView = (PaymentsTransfersPersonalNavigation.Destination) -> DestinationView
}
