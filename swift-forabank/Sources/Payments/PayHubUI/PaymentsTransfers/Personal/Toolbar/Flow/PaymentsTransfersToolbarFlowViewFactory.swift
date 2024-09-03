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
    public let makeDestination: MakeDestination
    public let makeFullScreen: MakeFullScreen
    
    public init(
        @ViewBuilder makeContent: @escaping MakeContent,
        @ViewBuilder makeDestination: @escaping MakeDestination,
        @ViewBuilder makeFullScreen: @escaping MakeFullScreen
    ) {
        self.makeContent = makeContent
        self.makeDestination = makeDestination
        self.makeFullScreen = makeFullScreen
    }
}

public extension PaymentsTransfersToolbarFlowViewFactory {
    
    typealias MakeContent = () -> ContentView
    
    typealias State = PaymentsTransfersToolbarFlowState<Profile, QR>
    
    typealias Destination = State.Destination
    typealias MakeDestination = (Destination) -> ProfileView
    
    typealias FullScreen = State.FullScreen
    typealias MakeFullScreen = (FullScreen) -> QRView
}
