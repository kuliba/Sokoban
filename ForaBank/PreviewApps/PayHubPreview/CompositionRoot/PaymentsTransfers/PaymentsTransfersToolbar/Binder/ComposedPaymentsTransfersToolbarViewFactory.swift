//
//  ComposedPaymentsTransfersToolbarViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub

struct ComposedPaymentsTransfersToolbarViewFactory<DestinationView, ProfileLabel, QRLabel> {
    
    let makeDestinationView: MakeDestinationView
    let makeProfileLabel: MakeProfileLabel
    let makeQRLabel: MakeQRLabel
}

extension ComposedPaymentsTransfersToolbarViewFactory {
    
    typealias MakeDestinationView = (PaymentsTransfersToolbarFlowState<ProfileModel, QRModel>.Destination) -> DestinationView
    typealias MakeProfileLabel = () -> ProfileLabel
    typealias MakeQRLabel = () -> QRLabel
}
