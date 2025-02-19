//
//  C2GPreviewAppApp.swift
//  C2GPreviewApp
//
//  Created by Igor Malyarov on 12.02.2025.
//

import SwiftUI

@main
struct C2GPreviewAppApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(
                inputViewModel: .makeUINInputViewModel(value: "1234567890123456789"),
                config: .preview
            )
            .preferredColorScheme(.light)
        }
    }
}
