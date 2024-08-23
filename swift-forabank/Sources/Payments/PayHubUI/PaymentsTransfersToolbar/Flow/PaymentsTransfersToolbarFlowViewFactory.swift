//
//  PaymentsTransfersToolbarFlowViewFactory.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersToolbarFlowViewFactory<ContentView, Profile, ProfileView, QR, QRView> {
    
    public let makeContent: MakeContent
    public let makeDestinationContent: MakeDestinationContent
    public let makeFullScreenContent: MakeFullScreenContent
    
    public init(
        @ViewBuilder makeContent: @escaping MakeContent,
        @ViewBuilder makeDestinationContent: @escaping MakeDestinationContent,
        @ViewBuilder makeFullScreenContent: @escaping MakeFullScreenContent
    ) {
        self.makeContent = makeContent
        self.makeDestinationContent = makeDestinationContent
        self.makeFullScreenContent = makeFullScreenContent
    }
}

public extension PaymentsTransfersToolbarFlowViewFactory {
    
    typealias MakeContent = () -> ContentView
    
    typealias State = PaymentsTransfersToolbarFlowState<Profile, QR>
    
    typealias Destination = State.Destination
    typealias MakeDestinationContent = (Destination) -> ProfileView
    
    typealias FullScreen = State.FullScreen
    typealias MakeFullScreenContent = (FullScreen) -> QRView
}
