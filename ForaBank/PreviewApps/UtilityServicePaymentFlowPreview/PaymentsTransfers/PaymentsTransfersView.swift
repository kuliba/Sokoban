//
//  PaymentsTransfersView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI
import UIPrimitives

struct PaymentsTransfersView: View {
    
    @StateObject private var viewModel: ViewModel
    private let config: Config
    
    init(
        viewModel: ViewModel,
        config: Config
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.config = config
    }
    
    var body: some View {
        
        Button("Utility", action: viewModel.openUtilityPayment)
            .navigationDestination(
                destination: viewModel.state.route.destination,
                dismissDestination: viewModel.resetDestination,
                content: destinationView
            )
    }
    
    @ViewBuilder
    private func destinationView(
        destination: Destination
    ) -> some View {
        
        switch destination {
        case .payByInstructions:
            Text("TBD: Pay by Instructions")
                .navigationTitle("Pay by Instructions")
                .navigationBarTitleDisplayMode(.inline)
            
        case let .utilityPrepayment(utilityPrepayment):
            utilityPrepaymentView(utilityPrepayment)
                .navigationTitle("Utility Prepayment View")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func utilityPrepaymentView(
        _ utilityPrepayment: UtilityPrepayment
    ) -> some View {
        
        UtilityPrepaymentWrapperView(
            viewModel: utilityPrepayment.viewModel,
            flowEvent: { viewModel.event(.utilityFlow(.prepayment($0.flowEvent))) },
            config: config
        )
        .navigationDestination(
            destination: utilityPrepayment.destination,
            dismissDestination: { viewModel.event(.utilityFlow(.prepayment(.dismissDestination))) },
            content: utilityPrepaymentDestinationView
        )
        .alert(item: utilityPrepayment.alert, content: utilityPrepaymentAlert)
    }
    
    @ViewBuilder
    private func utilityPrepaymentDestinationView(
        destination: UtilityPrepayment.Destination
    ) -> some View {
        
        switch destination {
        case let .operatorFailure(`operator`):
            Text("TBD: Operator Failure view for \(`operator`) with Pay by Instructions Button (!!!)")
            
        case .payByInstructions:
            Text("Pay by Instructions")
            
        case let .payment(response):
            Text("TBD: Payment with \(response)")
            
        case let .servicePicker(servicePickerState):
            servicePicker(servicePickerState)
                .navigationTitle(String(describing: servicePickerState.operator))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func utilityPrepaymentAlert(
        alert: UtilityPrepayment.Alert
    ) -> Alert {
        
        switch alert {
        case let .serviceFailure(serviceFailure):
            return serviceFailure.alert(
                event: { viewModel.event(.utilityFlow(.prepayment($0))) },
                map: {
                    switch $0 {
                    case .dismissAlert: return .dismissAlert
                    }
                }
            )
        }
    }
    
    private func servicePicker(
        _ servicePickerState: ServicePickerState
    ) -> some View {
        
        List {
            ForEach(servicePickerState.services.elements) { service in
                
                Button(String(service.id.prefix(24))) {
                    
                    viewModel.event(.utilityFlow(.prepayment(.select(.service(
                        service,
                        for: servicePickerState.`operator`
                    )))))
                }
            }
        }
        .navigationDestination(
            destination: servicePickerState.destination,
            dismissDestination: { viewModel.event(.utilityFlow(.prepayment(.dismissServicesDestination))) },
            content: servicesDestinationView
        )
        .alert(item: servicePickerState.alert, content: servicePickerAlert)
    }
    
    @ViewBuilder
    private func servicesDestinationView(
        destination: ServicePickerState.Destination
    ) -> some View {
        
        switch destination {
        case let .payment(response):
            Text("TBD: Payment with \(response)")
        }
    }
    
    private func servicePickerAlert(
        alert: ServicePickerState.Alert
    ) -> Alert {
        
        switch alert {
        case let .serviceFailure(serviceFailure):
            return serviceFailure.alert(
                event: { viewModel.event(.utilityFlow(.servicePicker($0))) },
                map: {
                    switch $0 {
                    case .dismissAlert: return .dismissAlert
                    }
                }
            )
        }
    }
}

extension PaymentsTransfersView {
    
    typealias UtilityPrepayment = PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment
    typealias ServicePickerState = UtilityPrepayment.Destination.ServicePickerState
    
    typealias Config = UtilityPrepaymentWrapperView.Config
    typealias Destination = ViewModel.State.Route.Destination
    typealias ViewModel = PaymentsTransfersViewModel
}

extension PaymentsTransfersViewModel.State.Route.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payByInstructions:
            return .payByInstructions
            
        case let .utilityPrepayment(utilityPrepayment):
            return .utilityFlow(ObjectIdentifier(utilityPrepayment.viewModel))
        }
    }
    
    enum ID: Hashable {
        
        case payByInstructions
        case utilityFlow(ObjectIdentifier)
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .operatorFailure(`operator`):
            return .operatorFailure(`operator`.id)
            
        case .payByInstructions:
            return .payByInstructions
            
        case .payment:
            return .payment
            
        case let .servicePicker(services):
            return .services(for: services.`operator`.id)
        }
    }
    
    enum ID: Hashable {
        
        case operatorFailure(Operator.ID)
        case payByInstructions
        case payment
        case services(for: Operator.ID)
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Alert: Identifiable {
    
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

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination.ServicePickerState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payment: return .payment
        }
    }
    
    enum ID: Hashable {
        
        case payment
    }
}

extension PaymentsTransfersViewModel.State.Route.Destination.UtilityPrepayment.Destination.ServicePickerState.Alert: Identifiable {
    
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

private extension UtilityPrepaymentFlowEvent {
    
    var flowEvent: PaymentsTransfersEvent.UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent {
        
        switch self {
        case .addCompany:
            return .addCompany
            
        case .payByInstructions:
            return .payByInstructions
            
        case .payByInstructionsFromError:
            return .payByInstructionsFromError
            
        case let .select(select):
            switch select {
            case let .lastPayment(lastPayment):
                return .select(.lastPayment(lastPayment))
                
            case let .operator(`operator`):
                return .select(.operator(`operator`))
            }
        }
    }
}

#Preview {
    
    NavigationView {
        
        PaymentsTransfersView(viewModel: .preview(), config: .preview)
    }
}
