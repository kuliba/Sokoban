//
//  FactoryBasedPreviewApp.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

@main
struct FactoryBasedPreviewApp: App {
    
    private let composer: Composer = .demo(
        initiateResult: .success(.preview)
    )
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(
                state: .demo,
                factory: composer.makeContentViewFactory()
            )
        }
    }
}

private extension Composer {
    
    static func demo(
        initiateResult: PaymentsManager.InitiateUtilityPrepaymentResult
    ) -> Self {
        
        let reducer = PaymentsReducer()
        let effectHandler = PaymentsEffectHandler(
            initiateUtilityPrepayment: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(initiateResult)
                }
            }
        )
        let paymentManager: PaymentsManager = .init(
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        let paymentsComposer = PaymentsComposer(paymentManager: paymentManager)
        
        return .init(makePaymentsView: paymentsComposer.makePaymentsView)
    }
}

private extension RootState {
    
    static let demo: Self = .init(
        payments: .init(destination: .deepLinkDemo),
        tab: .payments
    )
}

private extension PaymentsState.Destination {
    
    static let deepLinkDemo: Self = .utilityService(.prepayment(.preview))
}
