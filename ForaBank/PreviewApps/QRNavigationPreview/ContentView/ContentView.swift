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
            content: { fullScreen in
                
                NavigationView {
                    
                    switch fullScreen {
                    case let .qr(qr):
                        RxWrapperView(model: qr.flow) { state, event in
                            
                            QRFlowView(
                                state: state,
                                event: event,
                                contentView: {
                                    
                                    VStack {
                                        
                                        QRContentView(model: qr.content)
                                        
                                        Spacer()
                                        
                                        Button("Cancel") {
                                            
                                            // in the app QRModelWrapper has state case `cancelled` - which should be observed
                                            model.event(.dismiss)
                                        }
                                        .foregroundColor(.red)
                                    }
                                    .navigationTitle("QR Scanner")
                                },
                                destinationView: {
                                    
                                    switch $0 {
                                    case let .payments(payments):
                                        Text("TBD: Payments View \(String(describing: payments))")
                                    }
                                }
                            )
                        }
                    }
                }
            }
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
