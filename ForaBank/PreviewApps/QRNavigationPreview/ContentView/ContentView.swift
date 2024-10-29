//
//  ContentView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 27.10.2024.
//

import SwiftUI
import PayHubUI
import RxViewModel
import UIPrimitives

struct ContentView: View {
    
    @StateObject var model: ContentViewDomain.Flow
    
    var body: some View {
        
        NavigationView {
            
            Button {
                model.event(.select(.scanQR))
            } label: {
                Label("Scan QR", systemImage: "qrcode.viewfinder")
                    .imageScale(.large)
            }
            .fullScreenCover(
                cover: model.fullScreen,
                content: ContentViewFullScreenView.init
            )
            .navigationDestination(
                destination: model.destination,
                dismiss: { model.event(.dismiss) },
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
}

extension ContentViewDomain.Flow {
    
    var destination: Destination? {
        
        switch state.navigation {
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
        
        switch state.navigation {
        case .none:
            return nil
            
        case let .qr(node):
            return .qr(node.model)
            
        case .qrNavigation:
            return nil
        }
    }
    
    enum FullScreen {
        
        case qr(QRDomain.Binder)
    }
}

extension ContentViewDomain.Flow.Destination: Identifiable {
    
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

extension ContentViewDomain.Flow.FullScreen: Identifiable {
    
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

#Preview {
    ContentView(model: .preview)
}
