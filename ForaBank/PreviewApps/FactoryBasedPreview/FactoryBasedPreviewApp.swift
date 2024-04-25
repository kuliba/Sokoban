//
//  FactoryBasedPreviewApp.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

@main
struct FactoryBasedPreviewApp: App {
    
    private let composer: Composer
    
    init() {
        
        let paymentsComposer = PaymentsComposer()
        
        self.composer = .init(
            makePaymentsView: paymentsComposer.makePaymentsView
        )
    }
    
    var body: some Scene {
        
        WindowGroup {
        
            ContentView(
                state: .init(),
                factory: composer.makeContentViewFactory()
            )
        }
    }
}
