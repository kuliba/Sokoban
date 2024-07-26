//
//  ServicePaymentFlowStateWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import SwiftUI
import UIPrimitives

struct ServicePaymentFlowStateWrapperView: View {
    
    @StateObject private var flowModel: ServicePaymentFlowModel
    @StateObject private var contentModel: AnywayTransactionViewModel
    
    private let factory: Factory
    
    init(
        binder: ServicePaymentBinder,
        factory: Factory
    ) {
        self._flowModel = .init(wrappedValue: binder.flow)
        self._contentModel = .init(wrappedValue: binder.content)
        self.factory = factory
    }
    
    typealias Factory = ServicePaymentFlowFactory
    
    var body: some View {
        
        AnywayTransactionStateWrapperView(
            viewModel: contentModel
        ) { state, event in
            
            AnywayTransactionView(
                state: state,
                event: event,
                factory: .init(
                    makeElementView: factory.makeElementView,
                    makeFooterView: factory.makeFooterView
                )
            )
        }
        .alert(
            item: flowModel.state.alert,
            content: paymentFlowAlert(
                flowEvent: flowModel.event(_:),
                contentEvent: contentModel.event(_:)
            )
        )
        .bottomSheet(
            sheet: flowModel.state.bottomSheet,
            dismiss: { contentModel.event(.fraud(.cancel)) },
            content: { factory.bottomSheetContent($0.fraudPayload) }
        )
        .fullScreenCover(
            cover: flowModel.state.fullScreenCover,
            dismissFullScreenCover: { flowModel.event(.terminate) },
            content: { factory.fullScreenCoverContent($0.result) }
        )
        .padding(.bottom)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

extension ServicePaymentFlowState {

    var alert: Alert? {
        
        guard case let .alert(alert) = self
        else { return nil }
        
        return alert
    }
    
    var bottomSheet: BottomSheet? {
        
        guard case let .fraud(fraudPayload) = self
        else { return nil }
        
        return .init(fraudPayload: fraudPayload)
    }
    
    struct BottomSheet: BottomSheetCustomizable {
        
        let id = UUID()
        let fraudPayload: FraudNoticePayload
    }
    
    var fullScreenCover: FullScreenCover? {
        
        guard case let .fullScreenCover(result) = self
        else { return nil }
        
        return .init(result: result)
    }
    
    struct FullScreenCover: Identifiable {
        
        let id = UUID()
        let result: TransactionResult
    }
}

extension ServicePaymentFlowState.Alert: Identifiable {
    
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

private extension ServicePaymentFlowStateWrapperView {
    
    func paymentFlowAlert(
        flowEvent: @escaping (ServicePaymentFlowEvent) -> Void,
        contentEvent: @escaping (AnywayTransactionEvent) -> Void
    ) -> (ServicePaymentFlowState.Alert) -> Alert {
        
        return { alert in
            
            switch alert {
            case .paymentRestartConfirmation:
                return .init(
                    with: .paymentRestartConfirmation,
                    event: contentEvent
                )
                
            case let .serverError(errorMessage):
                return .init(
                    with: .serverError(message: errorMessage),
                    event: contentEvent
                )
                
            case let .terminalError(errorMessage):
                return .init(
                    with: .terminalError(message: errorMessage),
                    event: flowEvent
                )
            }
        }
    }
}

// MARK: - Alerts

private extension AlertModel
where PrimaryEvent == ServicePaymentFlowEvent,
      SecondaryEvent == ServicePaymentFlowEvent {
    
    static func terminalError(
        message: String
    ) -> Self {
        
        return .init(
            title: "Ошибка",
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: .terminate
            )
        )
    }
}
