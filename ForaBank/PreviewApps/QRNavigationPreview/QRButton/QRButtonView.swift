//
//  QRButtonView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 30.10.2024.
//

import SwiftUI

struct QRButtonView<FullScreenCoverContent>: View
where FullScreenCoverContent: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        Button {
            event(.select(.scanQR))
        } label: {
            Label("Scan QR", systemImage: "qrcode.viewfinder")
                .imageScale(.large)
        }
        .fullScreenCover(
            cover: state.fullScreen,
            dismiss: { event(.dismiss) },
            content: factory.makeFullScreenCoverContent
        )
        .navigationDestination(
            destination: state.destination,
            dismiss: { event(.dismiss) },
            content: {
                
                switch $0 {
                case let .qrNavigation(qrNavigation):
                    switch qrNavigation {
                    case let .payments(payments):
                        PaymentsView(model: payments)
                    }
                }
            }
        )
    }
}

extension QRButtonView {
    
    typealias State = QRButtonDomain.FlowDomain.State
    typealias Event = QRButtonDomain.FlowDomain.Event
    
    typealias Factory = QRButtonViewFactory<FullScreenCoverContent>
}

extension QRButtonDomain.FlowDomain.State {
    
    var destination: Destination? {
        
        switch navigation {
        case .none:
            return nil
            
        case .qr:
            return nil
            
        case let .qrNavigation(qrNavigation):
            return .qrNavigation(qrNavigation)
        }
    }
    
    enum Destination {
        
        case qrNavigation(QRNavigation)
    }
    
    var fullScreen: FullScreen? {
        
        switch navigation {
        case .none:
            return nil
            
        case let .qr(qr):
            return .qr(qr)
            
        case .qrNavigation:
            return nil
        }
    }
    
    enum FullScreen {
        
        case qr(QRDomain.Binder)
    }
}

extension QRButtonDomain.FlowDomain.State.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .qrNavigation(qrNavigation):
            switch qrNavigation {
            case let .payments(payments):
                return .qrNavigation(.payments(.init(payments)))
            }
        }
    }
    
    enum ID: Hashable {
        
        case qrNavigation(QRNavigation)
        
        enum QRNavigation: Hashable {
            
            case payments(ObjectIdentifier)
        }
    }
}

extension QRButtonDomain.FlowDomain.State.FullScreen: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .qr(qr):
            return .qr(.init(qr))
        }
    }
    
    enum ID: Hashable {
        
        case qr(ObjectIdentifier)
    }
}

// MARK: - Previews

#Preview {
    
    QRButtonView(
        state: .init(),
        event: { print($0) },
        factory: .init(
            makeFullScreenCoverContent: { _ in Text("FullScreenCoverContent") }
        )
    )
}
