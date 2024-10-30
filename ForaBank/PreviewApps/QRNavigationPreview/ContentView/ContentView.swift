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

// MARK: - Previews

#Preview {
    
    ContentView(flow: Node.preview().model)
}
