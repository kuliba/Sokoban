//
//  FastPaymentsSettingsPreviewApp.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import SwiftUI

@main
struct FastPaymentsSettingsPreviewApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            
            NavigationStack {
                
                UserAccountView(viewModel: .preview(
                    route: .init(),
                    getContractConsentAndDefault: { completion in
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            
                            completion(.inactive())
                        }
                    }
                ))
            }
        }
    }
}
