//
//  ComposedPaymentsTransfersToolbarViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub

public struct ComposedPaymentsTransfersToolbarViewFactory<DestinationView, FullScreenView, Profile, ProfileLabel, QR, QRLabel> {
    
    public let makeDestinationView: MakeDestinationView
    public let makeFullScreenView: MakeFullScreenView
    public let makeProfileLabel: MakeProfileLabel
    public let makeQRLabel: MakeQRLabel
    
    public init(
        makeDestinationView: @escaping MakeDestinationView,
        makeFullScreenView: @escaping MakeFullScreenView,
        makeProfileLabel: @escaping MakeProfileLabel,
        makeQRLabel: @escaping MakeQRLabel
    ) {
        self.makeDestinationView = makeDestinationView
        self.makeFullScreenView = makeFullScreenView
        self.makeProfileLabel = makeProfileLabel
        self.makeQRLabel = makeQRLabel
    }
}

public extension ComposedPaymentsTransfersToolbarViewFactory {
    
    typealias MakeDestinationView = (PaymentsTransfersToolbarFlowState<Profile, QR>.Destination) -> DestinationView
    typealias MakeFullScreenView = (PaymentsTransfersToolbarFlowState<Profile, QR>.FullScreen) -> FullScreenView
    typealias MakeProfileLabel = () -> ProfileLabel
    typealias MakeQRLabel = () -> QRLabel
}
