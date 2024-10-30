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
        
        NavigationView(content: qrButton)
    }
}

extension ContentView {
    
    func qrButton() -> some View {
        
        RxWrapperView(
            model: flow,
            makeContentView: {
                
                QRButtonView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeDestinationContent: {
                            
                            switch $0 {
                            case let .qrNavigation(qrNavigation):
                                switch qrNavigation {
                                case let .payments(payments):
                                    PaymentsView(model: payments)
                                }
                            }
                        },
                        makeFullScreenCoverContent: QRButtonFullScreenView.init
                    )
                )
            }
        )
    }
}

// MARK: - Previews

#Preview {
    
    ContentView(flow: Node.preview().model)
}
