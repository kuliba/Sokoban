//
//  UtilityPaymentFlowView.swift
//
//
//  Created by Igor Malyarov on 05.05.2024.
//

import OperatorsListComponents
import SwiftUI
import UIPrimitives

struct UtilityPaymentFlowView<Content, DestinationView>: View
where Content: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let content: () -> Content
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        content()
            .navigationDestination(
                destination: state.destination,
                dismissDestination: { event(.dismiss(.destination)) },
                content: destinationView
            )
            .alert(
                item: state.alert,
                content: utilityPrepaymentAlert(event: { event($0) })
            )
    }
    
    private func utilityPrepaymentAlert(
        event: @escaping (Event) -> Void
    ) -> (State.Alert) -> Alert {
        
        return { alert in
            
            return alert.serviceFailure.alert(
                event: event,
                map: {
                    switch $0 {
                    case .dismissAlert: return .dismiss(.alert)
                    }
                }
            )
        }
    }
}

extension UtilityPaymentFlowView {
    
    typealias Destination = State.Destination
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService

    typealias UtilityPaymentViewModel = AnywayTransactionViewModel
    typealias State = UtilityPaymentFlowState<Operator, Service, UtilityPrepaymentBinder>
    typealias Event = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
}

extension UtilityPaymentFlowState.Destination: Identifiable
where Operator: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .operatorFailure(operatorFailure):
            return .operatorFailure(operatorFailure.content.id)
            
        case .payByInstructions:
            return .payByInstructions
            
        case .payment:
            return .payment
            
        case let .servicePicker(state):
            return .services(for: state.content.`operator`.id)
        }
    }
    
    enum ID: Hashable {
        
        case operatorFailure(Operator.ID)
        case payByInstructions
        case payment
        case services(for: Operator.ID)
    }
}

extension UtilityPaymentFlowState.Alert: Identifiable {
    
    var id: ID {
        
        switch serviceFailure {
        case .connectivityError:
            return .serviceFailure(.connectivityError)
            
        case let .serverError(message):
            return .serviceFailure(.serverError(message))
        }
    }
    
    enum ID: Hashable {
        
        case serviceFailure(ServiceFailure)
    }
}

private extension ServiceFailureAlert.ServiceFailure {
    
    func alert<Event>(
        event: @escaping (Event) -> Void,
        map: @escaping (ServiceFailureEvent) -> Event
    ) -> Alert {
        
        self.alert(event: { event(map($0)) })
    }
    
    enum ServiceFailureEvent {
        
        case dismissAlert
    }
    
    private func alert(
        event: @escaping (ServiceFailureEvent) -> Void
    ) -> Alert {
        
        switch self {
        case .connectivityError:
            let model = alertModelOf(title: "Ошибка", message: "alert message")
            return .init(with: model, event: event)
            
        case let .serverError(message):
            let model = alertModelOf(title: "Ошибка", message: message)
            return .init(with: model, event: event)
        }
    }
    
    private func alertModelOf(
        title: String,
        message: String? = nil
    ) -> AlertModelOf<ServiceFailureEvent> {
        
        .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: .dismissAlert
            )
        )
    }
}
