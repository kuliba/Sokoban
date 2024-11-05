//
//  QRNavigationPreviewApp.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 27.10.2024.
//

import PayHubUI
import SwiftUI

@main
struct QRNavigationPreviewApp: App {
    
    let flow: ContentViewDomain.Flow = .preview()
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(model: flow)
        }
    }
}
