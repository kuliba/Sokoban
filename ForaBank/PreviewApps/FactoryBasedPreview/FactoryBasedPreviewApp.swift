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
        root: .init(spinner: .off),
        tab: .payments,
        payments: .init(
            destination: .utilityService(.prepayment(.init(
                lastPayments: .preview,
                operators: .preview
            )))
        )
    )
    
    private let composer: Composer = .demo(
        paymentsComposer: .demo(
            initiateResult: .success(.init(
                lastPayments: .preview,
                operators: .preview
            ))
        )
    )
    
    var body: some Scene {
        
        WindowGroup {
            
            composer.makeContentView(appState: appState)
        }
    }
}

private extension AppState {
    
    init(
        root: RootState,
        tab: MainTabState,
        payments: PaymentsState
    ) {
        self.rootState = root
        self.tabState = tab
        self.paymentsState = payments
    }
}

private extension Composer {
    
    static func demo(
        paymentsComposer: PaymentsComposer
    ) -> Self {
        
        return .init(makePaymentsView: paymentsComposer.makePaymentsView)
    }
}

private extension PaymentsComposer {
    
    static func demo(
        initiateResult: InitiateUtilityPrepaymentResult
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
        
        return .init(paymentManager: paymentManager)
    }
    
    typealias InitiateUtilityPrepaymentResult = PaymentsManager.InitiateUtilityPrepaymentResult
}
