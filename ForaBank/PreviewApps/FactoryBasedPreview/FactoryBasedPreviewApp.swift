//
//  FactoryBasedPreviewApp.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

@main
struct FactoryBasedPreviewApp: App {
    
    private let composer: Composer = .preview()
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(
                state: .init(
                    payments: .init(destination: .deepLinkDemo),
                    tab: .payments
                ),
                factory: composer.makeContentViewFactory()
            )
        }
    }
}

private extension PaymentsState.Destination {
    
    static let deepLinkDemo: Self = .prepaymentFlow(
        .utilityServicePayment(.init(
            lastPayments: .preview,
            operators: .preview
        ))
    )
}
