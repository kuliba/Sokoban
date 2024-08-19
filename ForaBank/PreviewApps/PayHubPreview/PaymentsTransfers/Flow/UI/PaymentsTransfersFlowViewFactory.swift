//
//  PaymentsTransfersFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

struct PaymentsTransfersFlowViewFactory<Content, DestinationContent, FullScreenContent, ProfileButtonLabel, QRButtonLabel>
where Content: View,
      DestinationContent: View,
      ProfileButtonLabel: View,
      QRButtonLabel: View {
    
    @ViewBuilder let makeContent: MakeContent
    @ViewBuilder let makeDestinationContent: MakeDestinationContent
    @ViewBuilder let makeFullScreenContent: MakeFullScreenContent
    @ViewBuilder let makeProfileButtonLabel: MakeProfileButtonLabel
    @ViewBuilder let makeQRButtonLabel: MakeQRButtonLabel
}

extension PaymentsTransfersFlowViewFactory {
    
    typealias MakeContent = () -> Content
    typealias Navigation = PaymentsTransfersFlowState.Navigation
    typealias MakeDestinationContent = (Navigation.Destination) -> DestinationContent
    typealias MakeFullScreenContent = (Navigation.FullScreen) -> FullScreenContent
    typealias MakeProfileButtonLabel = () -> ProfileButtonLabel
    typealias MakeQRButtonLabel = () -> QRButtonLabel
}
