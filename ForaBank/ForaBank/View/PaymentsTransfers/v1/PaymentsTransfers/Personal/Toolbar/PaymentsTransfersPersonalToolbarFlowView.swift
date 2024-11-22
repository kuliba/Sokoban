//
//  PaymentsTransfersPersonalToolbarFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import SwiftUI

struct PaymentsTransfersPersonalToolbarFlowView<ContentView, ProfileView, QRView>: View
where ContentView: View,
      ProfileView: View,
      QRView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
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

extension PaymentsTransfersPersonalToolbarFlowView {
    
    typealias Domain = PaymentsTransfersPersonalToolbarDomain
    typealias State = Domain.FlowDomain.State
    typealias Event = Domain.FlowDomain.Event
    typealias Factory = PaymentsTransfersPersonalToolbarFlowViewFactory<ContentView, ProfileView, QRView>
}

extension PaymentsTransfersPersonalToolbarDomain.FlowDomain.State {
    
    var destination: Destination? {
        
        guard case let .profile(profile) = navigation
        else { return nil }
        
        return .profile(profile)
    }
    
    enum Destination {
        
        case profile(ProfileModelStub)
    }
    
    var fullScreen: FullScreen? {
        
        guard case let .qr(qr) = navigation
        else { return nil }
        
        return .qr(qr)
    }
    
    enum FullScreen {
        
        case qr(QRModelStub)
    }
}

extension PaymentsTransfersPersonalToolbarDomain.FlowDomain.State.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .profile: return .profile
        }
    }
    
    enum ID: Hashable {
        
        case profile
    }
}

extension PaymentsTransfersPersonalToolbarDomain.FlowDomain.State.FullScreen: Identifiable {
    
    var id: ID {
        
        switch self {
        case .qr: return .qr
        }
    }
    
    enum ID: Hashable {
        
        case qr
    }
}
