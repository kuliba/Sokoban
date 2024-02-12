//
//  OTPInputComponentPreviewApp.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

@main
struct OTPInputComponentPreviewApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(viewModel: .init())
        }
    }
}
