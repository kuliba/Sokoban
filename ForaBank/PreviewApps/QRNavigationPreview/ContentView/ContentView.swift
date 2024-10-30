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
                    factory: .init()
                )
            }
        )
    }
}

// MARK: - Previews

#Preview {
    
    ContentView(flow: Node.preview().model)
}
