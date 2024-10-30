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
    
    let flow: QRButtonDomain.FlowDomain.Flow
    
    var body: some View {
        
        NavigationView {
            
            QRButtonStateWrapperView(flow: flow)
        }
    }
}

extension QRButtonDomain.FlowDomain.Flow {
    
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

extension QRButtonDomain.FlowDomain.Flow.Destination: Identifiable {
    
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

extension QRButtonDomain.FlowDomain.Flow.FullScreen: Identifiable {
    
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
    
    ContentView(flow: Node.preview().model)
}
