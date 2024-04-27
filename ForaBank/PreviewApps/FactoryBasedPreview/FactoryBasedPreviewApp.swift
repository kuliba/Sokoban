//
//  FactoryBasedPreviewApp.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

@main
struct FactoryBasedPreviewApp: App {
    
    private let appState = AppState(
        rootState: .init(spinner: .off),
        tabState: .payments,
        paymentsState: .init(
            destination: .utilityService(.prepayment(.init(
                lastPayments: .preview,
                operators: .preview
            )))
        )
    )
    
    private let composer: Composer = .demo(
        initiateResult: .success(.init(
            lastPayments: .preview,
            operators: .preview
        ))
    )
    
    var body: some Scene {
        
        WindowGroup {
            
            composer.makeContentView(appState: appState)
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
