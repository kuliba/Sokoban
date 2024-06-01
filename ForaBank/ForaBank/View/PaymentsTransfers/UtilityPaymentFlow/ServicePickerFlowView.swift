//
//  ServicePickerFlowView.swift
//  
//
//  Created by Igor Malyarov on 10.05.2024.
//

import SwiftUI
import UIPrimitives

struct ServicePickerFlowView<LastPayment, Operator, Service, ContentView, DestinationView>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let content: () -> ContentView
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        content()
            .navigationDestination(
                destination: state.destination,
                dismissDestination: { event(.prepayment(.dismiss(.servicesDestination))) },
                content: destinationView
            )
            .alert(
                item: state.alert,
                content: servicePickerAlert(event: { event(.servicePicker($0)) })
            )
    }
    
    private func servicePickerAlert(
        event: @escaping (Event.ServicePickerFlowEvent) -> Void
    ) -> (State.Alert) -> Alert {
        
        return { alert in
            
            return alert.serviceFailure.alert(
                event: event,
                map: {
                    switch $0 {
                    case .dismissAlert: return .dismissAlert
                    }
                }
            )
        }
    }
}

extension ServicePickerFlowView {
    
    typealias Destination = State.Destination
    
    typealias PaymentViewModel = ObservingAnywayTransactionViewModel
    typealias UtilityFlowState = UtilityPaymentFlowState<Operator, Service, UtilityPrepaymentViewModel, PaymentViewModel>
    typealias State = UtilityServicePickerFlowState<Operator, Service, PaymentViewModel>

    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, Service>
}

extension UtilityServicePickerFlowState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payment: return .payment
        }
    }
    
    enum ID: Hashable {
        
        case payment
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
            let model = alertModelOf(title: "Error!", message: "alert message")
            return .init(with: model, event: event)
            
        case let .serverError(message):
            let model = alertModelOf(title: "Error!", message: message)
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
