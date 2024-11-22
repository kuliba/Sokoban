//
//  PaymentsTransfersPersonalToolbarFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import SwiftUI

struct PaymentsTransfersPersonalToolbarFlowViewFactory<ContentView, ProfileView, QRView> {
    
     let makeContent: MakeContent
     let makeDestination: MakeDestination
     let makeFullScreen: MakeFullScreen
}

extension PaymentsTransfersPersonalToolbarFlowViewFactory {
    
    typealias MakeContent = () -> ContentView
    
    typealias Domain = PaymentsTransfersPersonalToolbarDomain
    typealias State = Domain.FlowDomain.State
    
    typealias Destination = State.Destination
    typealias MakeDestination = (Destination) -> ProfileView
    
    typealias FullScreen = State.FullScreen
    typealias MakeFullScreen = (FullScreen) -> QRView
}
