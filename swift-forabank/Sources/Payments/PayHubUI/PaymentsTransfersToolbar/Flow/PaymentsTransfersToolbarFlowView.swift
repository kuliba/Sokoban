//
//  PaymentsTransfersToolbarFlowView.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersToolbarFlowView<ContentView, Profile, ProfileView, QR, QRView>: View
where ContentView: View,
      ProfileView: View,
      QRView: View {
    
    private let state: State
    private let event: (Event) -> Void
    private let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
    
    public var body: some View {
        
        factory.makeContent()
            .navigationDestination(
                destination: state.destination,
                dismiss: { event(.dismiss) },
                content: factory.makeDestination
            )
            .fullScreenCover(
                cover: state.fullScreen,
                dismiss: { event(.dismiss) },
                content: factory.makeFullScreen
            )
    }
}

public extension PaymentsTransfersToolbarFlowView {
    
    typealias State = PaymentsTransfersToolbarFlowState<Profile, QR>
    typealias Event = PaymentsTransfersToolbarFlowEvent<Profile, QR>
    typealias Factory = PaymentsTransfersToolbarFlowViewFactory<ContentView, Profile, ProfileView, QR, QRView>
}

extension PaymentsTransfersToolbarFlowState {
    
    var destination: Destination? {
        
        guard case let .profile(profile) = navigation
        else { return nil }
        
        return .profile(profile)
    }
    
    public enum Destination {
        
        case profile(Profile)
    }
    
    var fullScreen: FullScreen? {
        
        guard case let .qr(qr) = navigation
        else { return nil }
        
        return .qr(qr)
    }
    
    public enum FullScreen {
        
        case qr(QR)
    }
}

extension PaymentsTransfersToolbarFlowState.Destination: Identifiable {
    
    public var id: ID {
        
        switch self {
        case .profile: return .profile
        }
    }
    
    public enum ID: Hashable {
        
        case profile
    }
}

extension PaymentsTransfersToolbarFlowState.FullScreen: Identifiable {
    
    public var id: ID {
        
        switch self {
        case .qr: return .qr
        }
    }
    
    public enum ID: Hashable {
        
        case qr
    }
}
