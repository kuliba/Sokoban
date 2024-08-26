//
//  ComposedPaymentsTransfersToolbarViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub

struct ComposedPaymentsTransfersToolbarViewFactory<DestinationView, FullScreenView, ProfileLabel, QRLabel> {
    
    let makeDestinationView: MakeDestinationView
    let makeFullScreenView: MakeFullScreenView
    let makeProfileLabel: MakeProfileLabel
    let makeQRLabel: MakeQRLabel
}

extension ComposedPaymentsTransfersToolbarViewFactory {
    
    typealias MakeDestinationView = (PaymentsTransfersToolbarFlowState<ProfileModel, QRModel>.Destination) -> DestinationView
    typealias MakeFullScreenView = (PaymentsTransfersToolbarFlowState<ProfileModel, QRModel>.FullScreen) -> FullScreenView
    typealias MakeProfileLabel = () -> ProfileLabel
    typealias MakeQRLabel = () -> QRLabel
}
