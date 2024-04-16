//
//  UtilityPaymentPreviewApp.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI

@main
struct UtilityPaymentPreviewApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(viewModel: .init())
        }
    }
}
