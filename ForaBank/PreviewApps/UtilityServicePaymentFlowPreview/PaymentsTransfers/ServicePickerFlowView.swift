//
//  ServicePickerFlowView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI
import UIPrimitives

struct ServicePickerFlowView<ContentView, DestinationView>: View
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
                dismissDestination: { event(.prepayment(.dismissServicesDestination)) },
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
            
            switch alert {
            case let .serviceFailure(serviceFailure):
                return serviceFailure.alert(
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
}

extension ServicePickerFlowView {
    
    typealias Destination = State.Destination
    
    typealias UtilityFlowState = UtilityPaymentFlowState<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    typealias State = UtilityFlowState.Destination.ServicePickerFlowState
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
}

//#Preview {
//    ServicePickerFlowView()
//}

extension UtilityPaymentFlowState.Destination.ServicePickerFlowState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payment: return .payment
        }
    }
    
    enum ID: Hashable {
        
        case payment
    }
}

extension UtilityPaymentFlowState.Destination.ServicePickerFlowState.Alert: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .serviceFailure(serviceFailure):
            return  .serviceFailure(serviceFailure)
        }
    }
    
    enum ID: Hashable {
        
        case serviceFailure(ServiceFailure)
    }
}

private extension ServiceFailure {
    
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
            let model = alertModelOf(title: "Ошибка", message: "Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже.")
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
