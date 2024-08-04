//
//  AnywayServicePickerFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import SwiftUI
import UIPrimitives

struct AnywayServicePickerFlowView<ServicePicker>: View
where ServicePicker: View {
    
    @ObservedObject var flowModel: FlowModel
    
    let factory: Factory
    
    var body: some View {
        
        factory.makeServicePicker(flowModel.state.content)
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
    typealias Factory = AnywayServicePickerFlowViewFactory<ServicePicker>
}

extension AnywayServicePickerFlowModel {
    
    var alert: State.Status.Alert? {
        
        guard case let .alert(alert) = state.status
        else { return nil }
        
        return alert
    }
    
    var destination: Destination? {
        
        switch state.status {
        case let .destination(destination):
            switch destination {
            case let .payByInstructions(node):
                return .payByInstructions(node.model)
                
            case let .payment(node):
                return .payment(node.model)
            }
            
        default:
            return nil
        }
    }
    
    enum Destination: Identifiable {
        
        case payByInstructions(PaymentsViewModel)
        case payment(AnywayFlowModel)
        
        var id: ID {
            switch self {
            case .payByInstructions: return .payByInstructions
            case .payment:           return .payment
            }
        }
        
        enum ID: Hashable {
            
            case payByInstructions, payment
        }
    }
}

extension AnywayServicePickerFlowState.Status.Alert: Identifiable {
    
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
        alert: AnywayServicePickerFlowState.Status.Alert
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
            factory.makeAnywayFlowView(anywayFlowModel)
        }
    }
}

private extension AnywayServicePickerFlowState.Status.Alert {
    
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
                event: .goTo(.payments)
            )
        )
    }
}
