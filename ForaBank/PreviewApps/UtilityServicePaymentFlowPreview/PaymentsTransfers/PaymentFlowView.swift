//
//  PaymentFlowView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct PaymentFlowView<Content: View>: View {
    
    let state: State
    let event: (Event) -> Void
    let content: () -> Content
    
    var body: some View {
        
        content()
            .sheet(
                modal: state.modal,
                dismissModal: { event(.dismissFraud) },
                content: paymentFlowModalView(event: { event(.fraud($0)) })
            )
            .alert(
                item: state.alert,
                content: paymentFlowAlert(event: event)
            )
    }
    
    private func paymentFlowModalView(
        event: @escaping (PaymentFraudMockView.Event) -> Void
    ) -> (State.Modal) -> PaymentFlowModalView {
        
        return {
            
            PaymentFlowModalView(state: $0, event: event)
        }
    }
    
    private func paymentFlowAlert(
        event: @escaping (UtilityServicePaymentFlowEvent) -> Void
    ) -> (State.Alert) -> Alert {
        
        return { alert in
            
            switch alert {
            case let .terminalError(errorMessage):
                
                return .init(
                    with: .init(
                        title: "Error!",
                        message: errorMessage,
                        primaryButton: .init(
                            type: .default,
                            title: "OK",
                            event: .dismissPaymentError
                        )
                    ),
                    event: event
                )
            }
        }
    }
}

extension PaymentFlowView {
    
    typealias State = UtilityServicePaymentFlowState
    typealias Event = UtilityServicePaymentFlowEvent
}

//#Preview {
//    PaymentFlowView()
//}

extension UtilityServicePaymentFlowState.Alert: Identifiable {
    
    var id: ID {
        
        switch self {
        case .terminalError: return  .terminalError
        }
    }
    
    enum ID: Hashable {
        
        case terminalError
    }
}

extension UtilityServicePaymentFlowState.Modal: Identifiable {
    
    var id: ID {
        
        switch self {
        case .fraud: return  .fraud
        }
    }
    
    enum ID: Hashable {
        
        case fraud
    }
}
