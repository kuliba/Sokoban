//
//  ContentView.swift
//  ShareSheetPreviewApp
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    var body: some View {
        
        VStack {
            
            shareButton(config: .default)
            shareButton(config: .mediumWithGrabber)
            shareButton(config: .withGrabber)
        }
    }
    
    private func shareButton(
        config: ShareSheetConfig
    ) -> some View {
        
        ShareButton(
            payload: .init(items: ["Payee: someone"]),
            config: config,
            label: { Text("Share") }
        )
    }
}

#Preview {
    
    ContentView()
}
