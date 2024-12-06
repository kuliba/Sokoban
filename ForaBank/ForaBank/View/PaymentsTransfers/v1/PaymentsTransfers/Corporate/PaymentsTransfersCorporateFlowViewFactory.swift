//
//  PaymentsTransfersCorporateFlowViewFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.11.2024.
//

struct PaymentsTransfersCorporateFlowViewFactory<ContentView, DestinationView, FullScreenCoverView> {
    
    let makeContentView: MakeContentView
    let makeFullScreenCoverView: MakeFullScreenCoverView
    let makeDestinationView: MakeDestinationView
}

extension PaymentsTransfersCorporateFlowViewFactory {
    
   typealias MakeContentView = () -> ContentView
   typealias MakeFullScreenCoverView = (PaymentsTransfersCorporateNavigation.FullScreenCover) -> FullScreenCoverView
   typealias MakeDestinationView = (PaymentsTransfersCorporateNavigation.Destination) -> DestinationView
}
