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
    
    let node: Node = .preview
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(model: node.model)
        }
    }
}
