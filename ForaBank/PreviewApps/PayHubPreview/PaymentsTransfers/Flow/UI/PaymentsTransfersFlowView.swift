//
//  PaymentsTransfersFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

struct PaymentsTransfersFlowView<Content, DestinationContent, ProfileButtonLabel, QRButtonLabel>: View
where Content: View,
      DestinationContent: View,
      ProfileButtonLabel: View,
      QRButtonLabel: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        factory.makeContent()
            .toolbar(content: toolbar)
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
    typealias Factory = PaymentsTransfersFlowViewFactory<Content, DestinationContent, ProfileButtonLabel, QRButtonLabel>
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

private extension PaymentsTransfersFlowView {
    
    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading, content: profileButton)
        ToolbarItem(placement: .topBarTrailing, content: qrButton)
    }
    
    private func profileButton() -> some View {
        
        Button {
            event(.open(.profile))
        } label: {
            factory.makeProfileButtonLabel()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func qrButton() -> some View {
        
        Button {
            event(.open(.qr))
        } label: {
            factory.makeQRButtonLabel()
        }
        .buttonStyle(PlainButtonStyle())
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
                    },
                    makeProfileButtonLabel: {
                        
                        if #available(iOS 14.5, *) {
                            Label("Profile", systemImage: "person.circle")
                                .labelStyle(.titleAndIcon)
                        } else {
                            HStack {
                                Image(systemName: "person.circle")
                                Text("Profile")
                            }
                        }
                    },
                    makeQRButtonLabel: {
                        
                        Image(systemName: "qrcode")
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
