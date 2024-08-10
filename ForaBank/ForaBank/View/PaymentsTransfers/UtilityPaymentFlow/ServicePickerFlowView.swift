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
    let contentView: () -> ContentView
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        contentView()
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
                connectivityErrorTitle: "Ошибка",
                connectivityErrorMessage: "alert message",
                serverErrorTitle: "Ошибка",
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
    
    typealias UtilityFlowState = UtilityPaymentFlowState<Operator, Service, UtilityPrepaymentViewModel>
    typealias State = UtilityServicePickerFlowState<Operator, Service>

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
