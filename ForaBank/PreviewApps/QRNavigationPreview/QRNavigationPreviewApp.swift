//
//  QRNavigationPreviewApp.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 27.10.2024.
//

import PayHubUI
import SwiftUI
import UIPrimitives

@main
struct QRNavigationPreviewApp: App {
    
    let flow = ContentViewModelComposer().compose()
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(model: flow)
                .onFirstAppear { flow.event(.select(.scanQR)) }
        }
    }
}
