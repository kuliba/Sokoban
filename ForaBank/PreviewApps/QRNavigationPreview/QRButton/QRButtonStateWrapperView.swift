//
//  QRButtonStateWrapperView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 30.10.2024.
//

import PayHubUI
import SwiftUI

struct QRButtonStateWrapperView: View {
    
    @StateObject var flow: QRButtonDomain.FlowDomain.Flow
    
    var body: some View {
        
        Button {
            flow.event(.select(.scanQR))
        } label: {
            Label("Scan QR", systemImage: "qrcode.viewfinder")
                .imageScale(.large)
        }
        .fullScreenCover(
            cover: flow.fullScreen,
            dismiss: { flow.event(.dismiss) },
            content: ContentViewFullScreenView.init
        )
        .navigationDestination(
            destination: flow.destination,
            dismiss: { flow.event(.dismiss) },
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

#Preview {
    
    QRButtonStateWrapperView(flow: Node.preview().model)
}
