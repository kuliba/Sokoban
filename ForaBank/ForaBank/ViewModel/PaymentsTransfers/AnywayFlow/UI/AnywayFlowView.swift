//
//  AnywayFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

import AnywayPaymentDomain
import SwiftUI
import UIPrimitives

struct AnywayFlowView<PaymentCompleteView: View>: View {
    
    @ObservedObject var flowModel: AnywayFlowModel
    
    let factory: AnywayPaymentFactory<IconDomain.IconView>
    let makePaymentCompleteView: (AnywayCompleted) -> PaymentCompleteView
    
    var body: some View {
        
        AnywayTransactionStateWrapperView(
            viewModel: flowModel.state.content
        ) { state, event in
            
            AnywayTransactionView(state: state, event: event, factory: factory)
        }
        .padding(.bottom)
        .ignoresSafeArea(.container, edges: .bottom)
        .alert(
            item: flowModel.state.alert,
            content: paymentFlowAlert(
                transactionEvent: flowModel.state.content.event,
                flowEvent: flowModel.event
            )
        )
        .fullScreenCover(
            cover: flowModel.state.fullScreenCover,
            dismissFullScreenCover: { flowModel.event(.goTo(.main)) },
            content: makePaymentCompleteView
        )
        .bottomSheet(
            sheet: flowModel.state.sheet,
            dismiss: { flowModel.state.content.event(.fraud(.cancel)) },
            content: paymentFlowModalView(
                event: { flowModel.state.content.event(.fraud($0)) }
            )
        )
    }
}

private extension AnywayFlowState {
    
    var alert: Status.Alert? {
        
        guard case let .alert(alert) = status
        else { return nil }
        
        return alert
    }
    
    var fullScreenCover: Status.Completed? {
        
        guard case let .completed(completed) = status
        else { return nil }
        
        return completed
    }
    
    var sheet: FraudNoticePayload? {
        
        guard case let .fraud(fraud) = status
        else { return nil }
        
        return fraud
    }
}

extension AnywayFlowState.Status.Alert: Identifiable {
    
    var id: ID {
        
        switch self {
        case .paymentRestartConfirmation:
            return .paymentRestartConfirmation
        
        case .serverError:
            return .serverError
        
        case .terminalError:
            return .terminalError
        }
    }
    
    enum ID: Hashable {
        
        case paymentRestartConfirmation
        case serverError
        case terminalError
    }
}

extension AnywayFlowState.Status.Completed: Identifiable {
    
    var id: ID {
        
        switch result {
        case .failure: return .fraud
        case .success: return .report
        }
    }
    
    enum ID: Hashable {
        
        case report, fraud
    }
}

extension FraudNoticePayload: BottomSheetCustomizable {}

extension FraudNoticePayload: Identifiable {
    
    var id: String { title + formattedAmount }
}

private extension AnywayFlowView {
    
    func paymentFlowAlert(
        transactionEvent: @escaping (AnywayTransactionEvent) -> Void,
        flowEvent: @escaping (AnywayFlowEvent) -> Void
    ) -> (AnywayFlowState.Status.Alert) -> Alert {
        
        return { alert in
            
            switch alert {
            case .paymentRestartConfirmation:
                return .init(
                    with: .paymentRestartConfirmation,
                    event: transactionEvent
                )
                
            case let .serverError(errorMessage):
                return .init(
                    with: .serverError(message: errorMessage),
                    event: transactionEvent
                )
                
            case let .terminalError(errorMessage):
                return .init(
                    with: .terminalError(message: errorMessage),
                    event: flowEvent
                )
            }
        }
    }
    
    func paymentFlowModalView(
        event: @escaping (FraudEvent) -> Void
    ) -> (FraudNoticePayload) -> FraudNoticeView {
        
        return { fraud in
            
            FraudNoticeView(state: fraud, event: event) }
    }
}

private extension AlertModel
where PrimaryEvent == AnywayFlowEvent,
      SecondaryEvent == AnywayFlowEvent {
    
    static func terminalError(
        message: String
    ) -> Self {
        
        return .init(
            title: "Ошибка",
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: .dismissDestination
            )
        )
    }
}
