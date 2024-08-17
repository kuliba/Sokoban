//
//  PaymentsTransfersFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

struct PaymentsTransfersFlowView<Content: View, DestinationContent: View>: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        factory.makeContent()
            .navigationDestination(
                destination: state.destination,
                dismiss: { event(.dismiss) },
                content: factory.makeDestinationContent
            )
    }
}

extension PaymentsTransfersFlowView {
    
    typealias State = PaymentsTransfersFlowState
    typealias Event = PaymentsTransfersFlowEvent
    typealias Factory = PaymentsTransfersFlowViewFactory<Content, DestinationContent>
}

extension PaymentsTransfersFlowState.Destination: Identifiable {
    
    public var id: ID {
        
        switch self {
        case .profile: return .profile
        case .qr:      return .qr
        }
    }
    
    public enum ID: Hashable {
        
        case profile, qr
    }
}
