//
//  QRButton.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 30.10.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI

struct QRButtonFactory {
    
    let flow: () -> QRButtonDomain.FlowDomain.Flow
    
    func makeQRButton<V: View>(
        label: @escaping () -> V
    ) -> some View {
        
        QRButton(
            flow: flow(),
            factory: .init(
                makeButtonLabel: label,
                makeDestinationContent: { _ in Text("") },
                makeFullScreenCoverContent: { _ in Text("") }
            )
        )
    }
}

struct QRButton<ButtonLabel, DestinationContent, FullScreenCoverContent>: View
where ButtonLabel: View,
      DestinationContent: View,
      FullScreenCoverContent: View {
    
    let flow: Flow
    let factory: Factory
    
    var body: some View {
        
        QRButtonFactory(flow: { flow }).makeQRButton(label: { Text("ScanQR") })
        
        RxWrapperView(
            model: flow,
            makeContentView: {
                
                QRButtonView(state: $0, event: $1, factory: factory)
            }
        )
    }
}

extension QRButton {
    
    typealias Flow = QRButtonDomain.FlowDomain.Flow
    
    typealias Factory = QRButtonViewFactory<ButtonLabel, DestinationContent, FullScreenCoverContent>
}

// MARK: - Previews

#Preview {
    QRButton(
        flow: Node.preview().model,
        factory: .init(
            makeButtonLabel: { Text("Scan QR") },
            makeDestinationContent: { _ in Text("DestinationContent") },
            makeFullScreenCoverContent: { _ in Text("FullScreenCoverContent") }
        )
    )
}
