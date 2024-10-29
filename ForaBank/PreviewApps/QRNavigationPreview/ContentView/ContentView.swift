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
        
        Button {
            model.event(.select(.scanQR))
        } label: {
            Label("Scan QR", systemImage: "qrcode.viewfinder")
                .imageScale(.large)
        }
        .fullScreenCover(
            cover: model.fullScreen,
            dismiss: { model.event(.dismiss) },
            content: ContentViewFullScreenView.init
        )
    }
}

extension ContentViewDomain.Flow {
    
    var fullScreen: FullScreen? {
        
        switch state.navigation {
        case .none:
            return nil
            
        case let .qr(qr):
            return .qr(qr)
        }
    }
    
    enum FullScreen {
        
        case qr(QRDomain.Binder)
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
