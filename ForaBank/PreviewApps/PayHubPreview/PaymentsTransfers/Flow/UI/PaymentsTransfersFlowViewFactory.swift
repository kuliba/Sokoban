//
//  PaymentsTransfersFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

struct PaymentsTransfersFlowViewFactory<Content, DestinationContent, ProfileButtonLabel, QRButtonLabel>
where Content: View,
      DestinationContent: View,
      ProfileButtonLabel: View,
      QRButtonLabel: View {
    
    @ViewBuilder let makeContent: MakeContent
    @ViewBuilder let makeDestinationContent: MakeDestinationContent
    @ViewBuilder let makeProfileButtonLabel: MakeProfileButtonLabel
    @ViewBuilder let makeQRButtonLabel: MakeQRButtonLabel
}

extension PaymentsTransfersFlowViewFactory {
    
    typealias MakeContent = () -> Content
    typealias MakeDestinationContent = (PaymentsTransfersFlowState.Destination) -> DestinationContent
    typealias MakeProfileButtonLabel = () -> ProfileButtonLabel
    typealias MakeQRButtonLabel = () -> QRButtonLabel
}
