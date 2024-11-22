//
//  ComposedPaymentsTransfersPersonalToolbarViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import SwiftUI

struct ComposedPaymentsTransfersPersonalToolbarViewFactory<DestinationView, FullScreenView, ProfileLabel, QRLabel> {
    
    let makeDestinationView: MakeDestinationView
    let makeFullScreenView: MakeFullScreenView
    let makeProfileLabel: MakeProfileLabel
    let makeQRLabel: MakeQRLabel
}

extension ComposedPaymentsTransfersPersonalToolbarViewFactory {
    
    typealias Domain = PaymentsTransfersPersonalToolbarDomain
    typealias State = Domain.FlowDomain.State
    
    typealias Destination = State.Destination
    typealias MakeDestinationView = (Destination) -> DestinationView
    
    typealias FullScreen = State.FullScreen
    typealias MakeFullScreenView = (FullScreen) -> FullScreenView
    
    typealias MakeProfileLabel = () -> ProfileLabel
    typealias MakeQRLabel = () -> QRLabel
}
