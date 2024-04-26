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
        prepaymentFlowManager: .preview(.success(.preview))
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
        prepaymentFlowManager: PaymentManager
    ) -> Self {
        
        let paymentsComposer = PaymentsComposer.demo(
            prepaymentFlowManager: prepaymentFlowManager
        )
        
        return .init(
            makePaymentsView: paymentsComposer.makePaymentsView
        )
    }
}

extension PaymentsComposer
where DestinationView == PaymentView<UtilityPrepaymentPickerMockView> {
    
    static func demo(
        prepaymentFlowManager: PaymentManager
    ) -> Self {
        
        self.init(
            prepaymentFlowManager: prepaymentFlowManager,
            makeDestinationView: {
                
                .init(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeUtilityPrepaymentView: UtilityPrepaymentPickerMockView.init
                    )
                )
            }
        )
    }
}

private extension RootState {
    
    static let demo: Self = .init(
        payments: .init(destination: .deepLinkDemo),
        tab: .payments
    )
}

private extension PaymentsState.Destination {
    
    static let deepLinkDemo: Self = .utilityService(
        .prepayment(.init(
            lastPayments: .preview,
            operators: .preview
        ))
    )
}
