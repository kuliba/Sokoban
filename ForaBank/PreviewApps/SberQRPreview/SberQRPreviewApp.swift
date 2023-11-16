//
//  SberQRPreviewApp.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

@main
struct SberQRPreviewApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            
            NavigationView {
                
                ContentView(
                    navigation: .fullScreenCover(.qrReader)
                )
            }
        }
    }
}
