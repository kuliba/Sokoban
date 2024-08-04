//
//  AnywayServicePickerFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import SwiftUI
import UIPrimitives

struct AnywayServicePickerFlowView<AnywayPaymentFlowView: View>: View {
    
    @ObservedObject var flowModel: FlowModel
    
    let makeAnywayFlowView: (AnywayFlowModel) -> AnywayPaymentFlowView
    
    var body: some View {
        
        //PaymentProviderServicePickerWrapperView(
        Text("")
        .alert(
            item: flowModel.alert,
            content: alertContent
        )
        .navigationDestination(
            destination: flowModel.destination,
            dismissDestination: { flowModel.event(.dismiss) },
            content: destinationContent
        )
    }
}

extension AnywayServicePickerFlowView {
    
    typealias FlowModel = AnywayServicePickerFlowModel
}

extension AnywayServicePickerFlowModel {
    
    var alert: State.Destination.Alert? {
        
        guard case let .alert(alert) = state.destination
        else { return nil }
        
        return alert
    }
    
    var destination: Destination? {
        
        switch state.destination {
        case let .payByInstructions(node):
            return .payByInstructions(node.model)
            
        case let .payment(node):
            return .payment(node.model)
            
        default:
            return nil
        }
    }
    
    enum Destination: Identifiable {
        
        case payByInstructions(PaymentsViewModel)
        case payment(AnywayFlowModel)
        
        var id: ID {
            switch self {
            case .payByInstructions:
                return .payByInstructions
            case .payment:
                return .payment
            }
        }
        
        enum ID: Hashable {
            
            case payByInstructions, payment
        }
    }
}

extension AnywayServicePickerFlowState.Destination.Alert: Identifiable {
    
    var id: ID {
        
        switch self {
        case .connectivity: return .connectivity
        case .serverError:  return .serverError
        }
    }
    
    enum ID: Hashable {
        
        case connectivity, serverError
    }
}

private extension AnywayServicePickerFlowView {
    
    func alertContent(
        alert: AnywayServicePickerFlowState.Destination.Alert
    ) -> Alert {
        
        return .init(
            with: .error(
                title: alert.title,
                message: alert.message
            ),
            event: flowModel.event(_:)
        )
    }
    
    @ViewBuilder
    func destinationContent(
        destination: AnywayServicePickerFlowModel.Destination
    ) -> some View {
        
        switch destination {
        case let .payByInstructions(paymentsViewModel):
            PaymentsView(viewModel: paymentsViewModel)
            
        case let .payment(anywayFlowModel):
            makeAnywayFlowView(anywayFlowModel)
        }
    }
}

private extension AnywayServicePickerFlowState.Destination.Alert {
    
    var title: String {
        
        switch self {
        case .connectivity:
            return ""
            
        case .serverError:
            return "Ошибка"
        }
    }
    
    var message: String {
        
        switch self {
        case .connectivity:
            return "Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже."
            
        case let .serverError(message):
            return message
        }
    }
}

private extension AlertModel
where PrimaryEvent == AnywayServicePickerFlowEvent,
      SecondaryEvent == AnywayServicePickerFlowEvent {
    
    static func error(
        title: String,
        message: String
    ) -> Self {
        
        return .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: .goToPayments
            )
        )
    }
}
