//
//  PaymentsTransfersFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import SwiftUI

struct PaymentsTransfersFlowView<Content, DestinationContent, FullScreenContent, Toolbar>: View
where Content: View,
      DestinationContent: View,
      FullScreenContent: View,
      Toolbar: ToolbarContent {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        factory.makeContent()
            .toolbar {
                factory.makeToolbar({ event(.open($0)) })
            }
            .navigationDestination(
                destination: state.destination,
                dismiss: { event(.dismiss) },
                content: factory.makeDestinationContent
            )
            .fullScreenCover(
                cover: state.fullScreen,
                dismiss: { event(.dismiss) },
                content: factory.makeFullScreenContent
            )
    }
}

extension PaymentsTransfersFlowView {
    
    typealias State = PaymentsTransfersFlowState
    typealias Event = PaymentsTransfersFlowEvent
    typealias Factory = PaymentsTransfersFlowViewFactory<Content, DestinationContent, FullScreenContent, Toolbar>
}

extension PaymentsTransfersFlowState {
    
    var destination: Navigation.Destination? {
        
        guard case let .destination(destination) = navigation
        else { return nil }
        
        return destination
    }
    
    var fullScreen: Navigation.FullScreen? {
        
        guard case let .fullScreen(fullScreen) = navigation
        else { return nil }
        
        return fullScreen
    }
}

extension PaymentsTransfersFlowState.Navigation.Destination: Identifiable {
    
    public var id: ID {
        
        switch self {
        case .profile: return .profile
        }
    }
    
    public enum ID: Hashable {
        
        case profile
    }
}

extension PaymentsTransfersFlowState.Navigation.FullScreen: Identifiable {
    
    public var id: ID {
        
        switch self {
        case .qr:      return .qr
        }
    }
    
    public enum ID: Hashable {
        
        case qr
    }
}

struct PaymentsTransfersFlowView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            paymentsTransfersFlowView(.init())
                .previewDisplayName("Content")
            paymentsTransfersFlowView(.init(navigation: .destination(.profile(.preview()))))
                .previewDisplayName("Profile")
            paymentsTransfersFlowView(.init(navigation: .fullScreen(.qr(.preview()))))
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
                    makeDestinationContent: {
                        
                        switch $0 {
                        case let .profile(profileModel):
                            Text(String(describing: profileModel))
                        }
                    },
                    makeFullScreenContent: {
                        
                        switch $0 {
                        case let .qr(qrModel):
                            Text(String(describing: qrModel))
                        }
                    },
                    makeToolbar: { event in
                        
                        ToolbarItem(placement: .topBarLeading) {
                            
                            Button {
                                event(.profile)
                            } label: {
                                
                                if #available(iOS 14.5, *) {
                                    Label("Profile", systemImage: "person.circle")
                                        .labelStyle(.titleAndIcon)
                                } else {
                                    HStack {
                                        Image(systemName: "person.circle")
                                        Text("Profile")
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            
                            Button {
                                event(.qr)
                            } label: {
                                Image(systemName: "qrcode")
                            }
                            .buttonStyle(.plain)
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
