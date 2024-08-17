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

struct PaymentsTransfersFlowView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            paymentsTransfersFlowView(.init(destination: nil))
                .previewDisplayName("Content")
            paymentsTransfersFlowView(.init(destination: .profile(.preview())))
                .previewDisplayName("Profile")
            paymentsTransfersFlowView(.init(destination: .qr(.preview())))
                .previewDisplayName("Qr")
        }
    }
    
    private static func paymentsTransfersFlowView(
        _ state: PaymentsTransfersFlowState
    ) -> some View {
        
        NavigationView {
            
            PaymentsTransfersFlowView(
                state: state,
                event: { print($0) },
                factory: .init(
                    makeContent: { Text("Content") },
                    makeDestinationContent: { destination in
                        
                        switch destination {
                        case let .profile(profileModel):
                            Text(String(describing: profileModel))
                            
                        case let .qr(qrModel):
                            Text(String(describing: qrModel))
                        }
                    }
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension ProfileModel {
    
    static func preview() -> Self {
        
        return .init()
    }
}

extension QRModel {
    
    static func preview() -> Self {
        
        return .init()
    }
}
