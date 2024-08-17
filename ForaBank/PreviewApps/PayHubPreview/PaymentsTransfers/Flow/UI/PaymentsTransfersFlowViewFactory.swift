//
//  PaymentsTransfersFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

struct PaymentsTransfersFlowViewFactory<Content: View, DestinationContent: View> {
    
    let makeContent: MakeContent
    let makeDestinationContent: MakeDestinationContent
}

extension PaymentsTransfersFlowViewFactory {
    
    typealias MakeContent = () -> Content
    typealias MakeDestinationContent = (PaymentsTransfersFlowState.Destination) -> DestinationContent
}
