//
//  ServicePickerFlowView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI
import UIPrimitives

struct ServicePickerFlowView<Content: View, DestinationView: View>: View
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
    
    typealias State = UtilityPaymentFlowState.Destination.ServicePickerState
    typealias Event = UtilityPaymentFlowEvent
}

//#Preview {
//    ServicePickerFlowView()
//}

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
